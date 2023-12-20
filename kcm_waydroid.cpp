/**
 * SPDX-FileCopyrightText: Year Author <author@domain.com>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "kcm_waydroid.h"


#include <KPluginFactory>
#include <QProcess>

K_PLUGIN_CLASS_WITH_JSON(KCMWaydroid, "kcm_waydroid.json")

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

    QString executeInternal(const QString& program, const QStringList& arguments)
    {
        QProcess process = QProcess();
        process.start(program, arguments);
        process.waitForFinished();
        QByteArray data = process.readAllStandardOutput();
        QString str = QString::fromStdString(data.toStdString());     
        return str;
    }

    // Executes an external program and waits for it's execution to end
    template<typename... Args>
    QString execute(const QString& program, Args&&... args)
    {
        //Expand the argument list into a QStringList
        QStringList arguments = {std::forward<Args>(args)...};

        return executeInternal(program, arguments);
    }
    void checkIfRunning()
    {
        running = getStatus().compare("RUNNING") == 0;
    }

public:
    Q_INVOKABLE QString getProp(const QString& name)
    {
        if(!running)
            return QString();

        QString value = execute("waydroid", "prop", "get", "persist.waydroid." + name).trimmed();

        return value;
    }

    Q_INVOKABLE void setProp(const QString& name, const QString& value)
    {
        if(!running)
            return;

        execute("waydroid", "prop", "set", "persist.waydroid." + name, value);
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
