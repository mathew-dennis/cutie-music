#include "appcore.h"
#include "coverimageprovider.h"
#include <QLoggingCategory>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlEngine>
#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickView>
#include <QTranslator>

int main(int argc, char *argv[])
{
	QGuiApplication app(argc, argv);
	AppCore appCore;
	QString locale = QLocale::system().name();
	QTranslator translator;
	translator.load(QString(":/i18n/cutie-music_") + locale);
	app.installTranslator(&translator);
	CoverImageProvider coverProvider;
	QQmlApplicationEngine engine;
	engine.addImageProvider(QLatin1String("cover"), &coverProvider);
	QQmlContext *context = engine.rootContext();
	context->setContextProperty("cutieMusic", &appCore);
	context->setContextProperty("audioFileArgument", app.arguments().value(1));
	const QUrl url(QStringLiteral("qrc:/main.qml"));
	QObject::connect(
		&engine, &QQmlApplicationEngine::objectCreated, &app,
		[url](QObject *obj, const QUrl &objUrl) {
			if (!obj && url == objUrl)
				QCoreApplication::exit(-1);
		},
		Qt::QueuedConnection);
	engine.load(url);
	return app.exec();
}
