/**
 * SPDX-FileCopyrightText: Year Author <author@domain.com>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "kcm_waydroid.h"


#include <KPluginFactory>
#include <QProcess>
#include <QtConcurrent/QtConcurrent>
#include <QtWidgets/QCheckBox>

K_PLUGIN_CLASS_WITH_JSON(KCMWaydroid, "kcm_waydroid.json")

class CallbackEvent : public QEvent
{
public:
    explicit CallbackEvent(const QJSValue& callback, const QJSValueList& args) : QEvent(QEvent::User), callback(callback), args(args) {}

    QJSValue getCallback() const { return callback; }
    QJSValueList getArgs() const { return args; }

private:
    QJSValue callback;
    QJSValueList args;
};

class Waydroid : public QObject
{
    Q_OBJECT

public:
    Waydroid(QObject* parent = nullptr) : QObject(parent) 
    {
        //Prevent changing settings if waydroid isn't running
        checkIfRunning();
    }

    virtual ~Waydroid() = default;

private:
    bool running;

    static QString executeInternal(const QString& program, const QStringList& arguments)
    {
        QProcess process = QProcess();
        process.start(program, arguments);
        process.waitForFinished();
        QByteArray data = process.readAllStandardOutput();
        QString str = QString(data);     
        return str;
    }

    // Executes an external program and waits for it's execution to end
    template<typename... Args>
    static QString execute(const QString& program, Args&&... args)
    {
        //Expand the argument list into a QStringList
        QStringList arguments = {std::forward<Args>(args)...};

        return executeInternal(program, arguments);
    }


    bool event(QEvent* event) override
    {
        if(event->type() == QEvent::User)
        {
            CallbackEvent *callbackEvent = static_cast<CallbackEvent*>(event);
            QJSValue callback = callbackEvent->getCallback();
            QJSValueList args = callbackEvent->getArgs();
            callback.call(args);
            return true;
        }

        return QObject::event(event);
    }

public:
    Q_INVOKABLE void setProp(const QString& name, const QString& value, QJSValue callback)
    {
        if(!running)
            return;

        QtConcurrent::run([=]() 
        {
            execute("waydroid", "prop", "set", "persist.waydroid." + name, value);

            QJSValueList args;
            args << value;
            auto event = new CallbackEvent(callback, args);

            QCoreApplication::postEvent(this, event);
        });

    }

    Q_INVOKABLE void initProp(const QString& name, QJSValue callback)
    {
        if(!running)
            return;

        QtConcurrent::run([=]() 
        {
            auto value = execute("waydroid", "prop", "get", "persist.waydroid." + name).trimmed();

            QJSValueList args;
            args << value;
            auto event = new CallbackEvent(callback, args);

            QCoreApplication::postEvent(this, event);
        });
    }

    Q_INVOKABLE void checkIfRunning()
    {
        running = getStatus().compare("RUNNING") == 0;
        qDebug() << "Check" << running;
    }


    Q_INVOKABLE void stopSession()
    {
        execute("waydroid", "session", "stop");
        checkIfRunning();
    }

    Q_INVOKABLE void restartContainer()
    {
        execute("pkexec", "systemctl", "restart", "waydroid-container");
        checkIfRunning();
    }
    
    //Gets waydroid's session status. Possible states are 'RUNNING' and 'STOPPED'
    Q_INVOKABLE QString getStatus()
    {
        QString output = execute("waydroid", "status");   
        QRegularExpression regexp = QRegularExpression("Session:\\s+(?<status>\\w+)");
        QRegularExpressionMatch match = regexp.match(output);
        return match.captured("status");
    }

    Q_INVOKABLE bool isSessionRunning()
    {
        qDebug() << "is" << running;
        return running;
    }
};


KCMWaydroid::KCMWaydroid(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : KQuickAddons::ManagedConfigModule(parent, data, args)
{
    qmlRegisterType<Waydroid>("KCMWaydroid", 1, 0, "Waydroid");
    setButtons(NoAdditionalButton);
}

#include "kcm_waydroid.moc"
