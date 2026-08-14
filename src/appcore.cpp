#include "appcore.h"
#include <QDebug>
#include <attachedpictureframe.h>
#include <id3v2frame.h>
#include <id3v2tag.h>
#include <mpegfile.h>
#include <vorbisfile.h>
#include <xiphcomment.h>

namespace {

// Mirrors the formats CoverImageProvider knows how to pull art from, so
// "hasCover" only ever promises what image://cover/ can actually deliver.
bool hasEmbeddedCoverArt(const QFileInfo &entry)
{
	const QString filePath = entry.absoluteFilePath();
	const QString suffix = entry.suffix().toUpper();

	if (suffix == QStringLiteral("MP3")) {
		TagLib::MPEG::File audioFile(filePath.toUtf8().constData());
		TagLib::ID3v2::Tag *tag = audioFile.ID3v2Tag();
		return tag && !tag->frameList("APIC").isEmpty();
	} else if (suffix == QStringLiteral("OGG")) {
		TagLib::Ogg::Vorbis::File audioFile(
			filePath.toUtf8().constData());
		TagLib::Ogg::XiphComment *tag = audioFile.tag();
		return tag && !tag->pictureList().isEmpty();
	}

	return false;
}

} // namespace

AppCore::AppCore(QObject *parent)
	: QObject(parent)
{
	readTrackList(QStandardPaths::writableLocation(
		QStandardPaths::MusicLocation));
}

void AppCore::readTrackList(QDir dir)
{
	QFileInfoList dirlist = dir.entryInfoList();

	for (int i = 0; i < dirlist.size(); i++) {
		QFileInfo entry = dirlist.at(i);
		QString filePath = entry.absoluteFilePath();
		QUrl fileUrl = QUrl::fromLocalFile(filePath);
		if (entry.isDir()) {
			if (entry.fileName() != ".." && entry.fileName() != ".")
				readTrackList(QDir(filePath));
		} else if (entry.isFile() && !m_trackList.contains(fileUrl)) {
			QVariantMap musicFile;
			TagLib::FileRef tagF(filePath.toUtf8().constData());

			QString title;
			QString artist;
			if (!tagF.isNull() && tagF.tag()) {
				title = QString::fromUtf8(
					tagF.tag()->title().toCString());
				artist = QString::fromUtf8(
					tagF.tag()->artist().toCString());
			}
			if (title.trimmed().isEmpty())
				title = entry.completeBaseName();
			if (artist.trimmed().isEmpty())
				artist = tr("Unknown Artist");

			musicFile.insert("path", QVariant(fileUrl));
			musicFile.insert("title", QVariant(title));
			musicFile.insert("artist", QVariant(artist));
			musicFile.insert(
				"hasCover",
				QVariant(hasEmbeddedCoverArt(entry)));
			m_trackList.append(QVariant(musicFile));
			emit trackListChanged(m_trackList);
		}
	}
}

QVariantList AppCore::trackList()
{
	return m_trackList;
}
