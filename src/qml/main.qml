import Cutie
import Qt5Compat.GraphicalEffects
import QtMultimedia
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Window

// Authors: Alexey T. (vin4ter), Erik Inkinen
// Contributors: Mathew Dennis
CutieWindow {
    id: view
    property bool playedStatus: false
    property int value: 0
    property bool btnPlayslate: false
    property int toMove: 0
    property int colPlaylist: 0

    width: 400
    height: 800
    visible: true
    title: qsTr("Music")

    initialPage: CutiePage {
        width: view.width
        height: view.height

        Rectangle {
            id: miniControls

            height: 72
            color: Atmosphere.primaryAlphaColor
            radius: 20
            clip: true

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.bottomMargin: 12

            FastBlur {
                anchors.fill: parent
                source: playlistView
                radius: 70
            }

            MouseArea {
                anchors.left: parent.left
                anchors.right: buttonRow.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                onReleased: {
                    view.pageStack.push("qrc:/Player.qml", {});
                }
            }

            Rectangle {
                id: coverContainer
                width: 52
                height: 52
                radius: 12
                clip: true
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                color: "transparent"

                Image {
                    id: miniCover
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    source: cutieMusic.trackList[playlistView.currentIndex].path.toString().replace("file:///", "image://cover/")
                }
            }

            Column {
                anchors.left: coverContainer.right
                anchors.leftMargin: 12
                anchors.right: buttonRow.left
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 3

                CutieLabel {
                    width: parent.width
                    text: cutieMusic.trackList[playlistView.currentIndex].title
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }

                CutieLabel {
                    width: parent.width
                    text: cutieMusic.trackList[playlistView.currentIndex].artist
                    font.pixelSize: 13
                    opacity: 0.65
                    elide: Text.ElideRight
                }
            }

            Row {
                id: buttonRow
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                CutieButton {
                    id: miniPlay
                    width: 44
                    height: 44
                    icon.name: mediaPlayer.playbackState === MediaPlayer.PlayingState ? "media-playback-pause-symbolic" : "media-playback-start-symbolic"
                    icon.color: Atmosphere.textColor

                    onClicked: {
                        if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                            mediaPlayer.pause();
                        } else {
                            if (mediaPlayer.playbackState === MediaPlayer.StoppedState) {
                                mediaPlayer.source = cutieMusic.trackList[playlistView.currentIndex].path;
                            } else {
                                mediaPlayer.play();
                            }
                        }
                    }
                }

                CutieButton {
                    id: miniNext
                    width: 44
                    height: 44
                    icon.name: "media-skip-forward-symbolic"
                    icon.color: Atmosphere.textColor

                    onClicked: {
                        if (playlistView.currentIndex + 1 < cutieMusic.trackList.length) {
                            playlistView.currentIndex++;
                        } else {
                            playlistView.currentIndex = 0;
                        }
                        mediaPlayer.source = cutieMusic.trackList[playlistView.currentIndex].path;
                    }
                }
            }
        }

        MediaPlayer {
            id: mediaPlayer

            audioOutput: AudioOutput {}

            onMediaStatusChanged: {
                if (mediaStatus == MediaPlayer.EndOfMedia) {
                    if (playlistView.currentIndex + 1 < cutieMusic.trackList.length)
                        playlistView.currentIndex++;
                    else playlistView.currentIndex = 0;
                    mediaPlayer.source = cutieMusic.trackList[playlistView.currentIndex].path;
                } else if (mediaStatus == MediaPlayer.LoadedMedia) play();
            }

            onPlaybackStateChanged: {
                if (playbackState == MediaPlayer.PlayingState) {
                    miniPlay.icon.name = "media-playback-pause-symbolic";
                } else {
                    miniPlay.icon.name = "media-playback-start-symbolic";
                }
            }
            
            onErrorOccurred: (error, errorString) => {
                console.error(errorString);
            }
        }

        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: miniControls.top
            anchors.top: parent.top
            clip: true
            CutieListView {
                id: playlistView
                anchors.fill: parent
                anchors.bottomMargin: -miniControls.height
                model: cutieMusic.trackList
                delegate: playlistDelegate
                clip: true

                header: CutiePageHeader {
                    id: titleM
                    title: qsTr("Music")
                }

                footer: Item {
                    height: miniControls.height + 12
                }
            }
        }

        Component {
            id: playlistDelegate

            CutieListItem {
                highlighted: playlistView.currentIndex == index
                icon.source: modelData.path.toString().replace("file:///", "image://cover/")
                icon.width: 40
                icon.height: 40
                iconOverlay: false

                wrapMode: Text.NoWrap
                elide: Text.ElideRight
                maximumLineCount: 1

                text: modelData.title
                subText: modelData.artist
                onClicked: {
                    playlistView.currentIndex = index;
                    mediaPlayer.source = modelData.path;
                }
            }
        }
    }
}