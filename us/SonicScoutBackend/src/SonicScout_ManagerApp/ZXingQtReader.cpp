/*
 * Copyright 2020 Axel Waggershauser
*/
// SPDX-License-Identifier: Apache-2.0

#include <squirrel_scout_manager/squirrel_scout_manager.h> /* SCOUT:ADDED */

#include "ZXingQtReader.h"

#include <QDebug>

using namespace ZXingQt;

int SQUIRREL_SCOUT_MANAGER_portable_main(int argc0, SQUIRREL_SCOUT_MANAGER_portable_char* argv0[]) /* SCOUT:CHANGED */
{
	/* SCOUT:ADDED */
	int argc;
	char** argv;
	squirrel_scout_manager_init(argc0, argv0, &argc, &argv);

	if (argc != 2) {
		qDebug() << "Please supply exactly one image filename";
		return 1;
	}

	QString filePath = argv[1];

	QImage fileImage = QImage(filePath);

	if (fileImage.isNull()) {
		qDebug() << "Could not load the filename as an image:" << filePath;
		return 1;
	}

	auto hints = DecodeHints()
					 .setFormats(BarcodeFormat::Any)
					 .setTryRotate(false)
					 .setMaxNumberOfSymbols(10);

	auto results = ReadBarcodes(fileImage, hints);

	for (auto& result : results) {
		qDebug() << "Text:   " << result.text();
		qDebug() << "Format: " << result.format();
		qDebug() << "Content:" << result.contentType();
		qDebug() << "";

		/* SCOUT:ADDED */
		auto bytes = result.bytes();
		auto format = result.formatName().toStdString();
		squirrel_scout_manager_consume_qr(format.c_str(), bytes.data(), bytes.length());
	}

	squirrel_scout_manager_destroy(); /* SCOUT:ADDED */
	return results.isEmpty() ? 1 : 0;
}
