/**
 * SPDX-FileCopyrightText: Year Author <author@domanin.com>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

//HACK: Need to do this at project level
#undef QT_NO_CAST_FROM_ASCII

#include <KQuickAddons/ManagedConfigModule>

class KCMWaydroid : public KQuickAddons::ManagedConfigModule
{
    Q_OBJECT
public:
    KCMWaydroid(QObject *parent, const KPluginMetaData &data, const QVariantList &args);
};
