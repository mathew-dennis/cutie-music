#include <fileref.h>
#include <tag.h>
#include <attachedpictureframe.h>
#include <id3v2frame.h>
#include <id3v2tag.h>
#include <xiphcomment.h>
#include <vorbisfile.h>
#include <mpegfile.h>
#include <QQuickImageProvider>
#include <QImage>
#include <QImageReader>

class CoverImageProvider : public QQuickImageProvider {
    public:
	CoverImageProvider();

	QImage requestImage(const QString &id, QSize *size,
			    const QSize &requestedSize) override;
};