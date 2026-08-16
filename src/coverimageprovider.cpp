#include "coverimageprovider.h"

CoverImageProvider::CoverImageProvider()
	: QQuickImageProvider(QQuickImageProvider::Image)
{
}

QImage CoverImageProvider::requestImage(const QString &id, QSize *size,
					const QSize &requestedSize)
{
	Q_UNUSED(size);
	Q_UNUSED(requestedSize);
	TagLib::FileRef file(id.toUtf8().constData());

	QString fileType = id.right(3).toUpper();
	QImage image;

	if (fileType.compare(QString("MP3")) == 0) {
		TagLib::MPEG::File audioFile(
			(QString("/") + id).toUtf8().constData());
		TagLib::ID3v2::Tag *tag = audioFile.ID3v2Tag(true);
		TagLib::ID3v2::FrameList l = tag->frameList("APIC");
		if (!l.isEmpty()) {
			TagLib::ID3v2::AttachedPictureFrame *f =
				static_cast<TagLib::ID3v2::AttachedPictureFrame *>(
					l.front());
			image.loadFromData((const uchar *)f->picture().data(),
					   f->picture().size());
		}
	} else if (fileType.compare(QString("OGG")) == 0) {
		TagLib::Ogg::Vorbis::File audioFile(
			(QString("/") + id).toUtf8().constData());
		TagLib::Ogg::XiphComment *tag = audioFile.tag();
		if (tag && !(tag->pictureList().isEmpty())) {
			TagLib::FLAC::Picture *pic = tag->pictureList()[0];
			image.loadFromData(
				(const unsigned char *)pic->data().data(),
				(int)pic->data().size());
		}
	}

	if (image.isNull())
		image = QImage(":/cutie-music.svg");

	return image;
}