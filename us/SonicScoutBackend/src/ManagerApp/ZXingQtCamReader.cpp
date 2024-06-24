/*
 * Copyright 2020 Axel Waggershauser
*/
// SPDX-License-Identifier: Apache-2.0

#include <squirrel_scout_manager/squirrel_scout_manager.h> /* SCOUT:ADDED */

#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "ZXingQtReader.h"

int SQUIRREL_SCOUT_MANAGER_portable_main(int argc0, SQUIRREL_SCOUT_MANAGER_portable_char* argv0[]) /* SCOUT:CHANGED */
{
	/* SCOUT:ADDED */
	int argc;
	char** argv;
	squirrel_scout_manager_init(argc0, argv0, &argc, &argv);

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

	ZXingQt::registerQmlAndMetaTypes();

	QGuiApplication app(argc, argv);
	app.setApplicationName("ZXingQtCamReader");
	QQmlApplicationEngine engine;
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
	engine.load(QUrl(QStringLiteral("qrc:/ZXingQt5CamReader.qml")));
#else
	engine.load(QUrl(QStringLiteral("qrc:/ZXingQt6CamReader.qml")));
#endif
	if (engine.rootObjects().isEmpty())
		return -1;

	/* SCOUT:MODIFY */
	int ret = app.exec();
	squirrel_scout_manager_destroy();
	return ret;
}
