import Cutie
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtMultimedia

CutiePage {
    id: player

    width: view.width
    height: view.height
    function formatTime(ms) {
        if (isNaN(ms) || ms < 0) return "0:00";
        var totalSeconds = Math.floor(ms / 1000);
        var minutes = Math.floor(totalSeconds / 60);
        var seconds = totalSeconds % 60;
        return minutes + ":" + (seconds < 10 ? "0" : "") + seconds;
    }

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

    CutieSlider {
        id: slideritem

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: controls.top
        anchors.bottomMargin: 30
        from: 0
        to: mediaPlayer.duration

        value: mediaPlayer.position
        onMoved: {
            if (mediaPlayer.seekable)
                mediaPlayer.position = value;
        }
    }

    CutieLabel {
        anchors.top: slideritem.bottom
        anchors.left: slideritem.left
        anchors.leftMargin: 15
        text: formatTime(mediaPlayer.position)
        font.pixelSize: 12
        opacity: 0.8
    }

    CutieLabel {
        anchors.top: slideritem.bottom
        anchors.right: slideritem.right
        anchors.rightMargin: 15
        text: formatTime(mediaPlayer.duration)
        font.pixelSize: 12
        opacity: 0.8
    }

    Item {
        id: controls

        height: 90
        width: 250
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter

        CutieButton {
            id: previous
            width: 60
            height: 60
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 20
            anchors.right: implay.left
            icon.name: "media-skip-backward-symbolic"
            icon.color: Atmosphere.textColor
            color: "transparent"

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
            height: 66
            padding: 6
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            icon: miniPlay.icon



            background: Rectangle {
                color: "transparent"
                border.color: Atmosphere.textColor
                radius: width / 2
            }

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
            width: 60
            height: 60
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 20
            anchors.left: implay.right
            icon.name: "media-skip-forward-symbolic"
            icon.color: Atmosphere.textColor
            color: "transparent"

            onClicked: {
                if (playlistView.currentIndex + 1 < cutieMusic.trackList.length)
                    playlistView.currentIndex++;
                else playlistView.currentIndex = 0;
                mediaPlayer.source = cutieMusic.trackList[playlistView.currentIndex].path;
            }
        }
    }
}
