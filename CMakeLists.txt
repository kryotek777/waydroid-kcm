cmake_minimum_required(VERSION 3.16)

project(waydroidkcm)

set(QT_MIN_VERSION "5.15.0")
set(KF5_MIN_VERSION "5.97.0")

find_package(ECM ${KF5_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)

find_package(Qt5 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS
    Quick
    Core
)

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS
    I18n
    KCMUtils
    Declarative
    Config
)

kcoreaddons_add_plugin(kcm_waydroid INSTALL_NAMESPACE "plasma/kcms/systemsettings")

target_sources(kcm_waydroid PRIVATE kcm_waydroid.cpp)

target_link_libraries(kcm_waydroid
    Qt5::Core
    KF5::CoreAddons
    KF5::I18n
    KF5::QuickAddons
)

kpackage_install_package(package kcm_waydroid kcms)

kcmutils_generate_desktop_file(kcm_waydroid)