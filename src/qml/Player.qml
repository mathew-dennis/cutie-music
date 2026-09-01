import Cutie
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtMultimedia

CutiePage {
    id: player

    width: view.width
    height: view.height

    Image {
        id: image

        x: 83
        width: 234
        height: 236
        anchors.top: parent.top
        source: cutieMusic.trackList[playlistView.currentIndex].path.toString().replace("file:///", "image://cover/")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 58
        sourceSize.height: 800
        sourceSize.width: 800
        fillMode: Image.PreserveAspectFit
    }

    CutieLabel {
        id: text1

        width: parent.width - 50
        text: cutieMusic.trackList[playlistView.currentIndex].title
        anchors.top: image.bottom
        anchors.topMargin: 20
        font.pixelSize: 28
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.horizontalCenter: parent.horizontalCenter
        font.weight: Font.Black
        elide: Text.ElideRight
    }

    CutieLabel {
        id: text2

        width: parent.width - 50
        text: cutieMusic.trackList[playlistView.currentIndex].artist
        anchors.top: text1.bottom
        anchors.topMargin: 20
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.horizontalCenter: parent.horizontalCenter
        elide: Text.ElideRight
    }

    Item {
        id: controls

        height: 60
        width: 138
        anchors.bottom: slideritem.top
        anchors.bottomMargin: 25
        anchors.horizontalCenter: parent.horizontalCenter

        CutieButton {
            id: previous
            width: 66
            height: 60
            anchors.rightMargin: 20
            anchors.right: implay.left
            icon.name: "media-skip-backward-symbolic"
            icon.color: Atmosphere.textColor

            onClicked: {
                if (playlistView.currentIndex > 0)
                    playlistView.currentIndex--;
                else playlistView.currentIndex = cutieMusic.trackList.length - 1;
                mediaPlayer.source = cutieMusic.trackList[playlistView.currentIndex].path;
            }
        }

        CutieButton {
            id: implay
            width: 66
            height: 60
            anchors.horizontalCenter: parent.horizontalCenter
            icon: miniPlay.icon

            onClicked: {
                if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                    mediaPlayer.pause();
                } else {
                    if (mediaPlayer.playbackState === MediaPlayer.StoppedState) {
                        mediaPlayer.source = cutieMusic.trackList[playlistView.currentIndex].path;
                    } else mediaPlayer.play();
                }
            }
        }

        CutieButton {
            id: next
            width: 66
            height: 60
            anchors.leftMargin: 20
            anchors.left: implay.right
            icon.name: "media-skip-forward-symbolic"
            icon.color: Atmosphere.textColor

            onClicked: {
                if (playlistView.currentIndex + 1 < cutieMusic.trackList.length)
                    playlistView.currentIndex++;
                else playlistView.currentIndex = 0;
                mediaPlayer.source = cutieMusic.trackList[playlistView.currentIndex].path;
            }
        }
    }

    CutieSlider {
        id: slideritem

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 75
        from: 0
        to: mediaPlayer.duration

        value: mediaPlayer.position
        onMoved: {
            if (mediaPlayer.seekable)
                mediaPlayer.position = value;
        }
    }
}
