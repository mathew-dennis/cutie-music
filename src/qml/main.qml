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
    property string searchQuery: ""
    property var filteredTracks: cutieMusic.trackList.filter(function(item) {
        if (!view.searchQuery) return true;
        var q = view.searchQuery.toLowerCase();
        return item.title.toLowerCase().includes(q) ||
               item.artist.toLowerCase().includes(q);
    })

    width: 400
    height: 800
    visible: true
    title: qsTr("Music")

    initialPage: CutiePage {
        width: view.width
        height: view.height

        Rectangle {
            id: miniControls

            height: 70
            radius: 20
            color: Atmosphere.primaryAlphaColor
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 10
            clip: true

            FastBlur {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: view.height
                source: playlistView
                radius: 70
                clip: true 
            }

            Image {
                id: miniCover
                y: 10
                width: 50
                height: 50
                anchors.leftMargin: 10
                anchors.left: parent.left
                fillMode: Image.PreserveAspectCrop
                source: view.filteredTracks[playlistView.currentIndex].path.toString().replace("file:///", "image://cover/")
            }

            CutieLabel {
                anchors.top: parent.top
                anchors.topMargin: 14
                anchors.leftMargin: 15
                anchors.left: miniCover.right
                anchors.rightMargin: 10
                anchors.right: miniPlay.left
                text: view.filteredTracks[playlistView.currentIndex].title
                font.pixelSize: 16
                font.weight: Font.Bold
                elide: Text.ElideRight
            }

            CutieLabel {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 14
                anchors.leftMargin: 15
                anchors.left: miniCover.right
                anchors.rightMargin: 10
                anchors.right: miniPlay.left
                text: view.filteredTracks[playlistView.currentIndex].artist
                font.pixelSize: 13
                elide: Text.ElideRight
            }

            Item {
                x: 0
                y: 0
                height: parent.height
                width: parent.width
                z: 100

                MouseArea {
                    anchors.fill: parent
                    onReleased: {
                        view.pageStack.push("qrc:/Player.qml", {});
                    }
                }
            }

            CutieButton {
                id: miniPlay
                y: 10
                width: 45
                height: 50
                anchors.rightMargin: 5
                anchors.right: miniNext.left
                icon.name: "media-playback-start-symbolic"
                icon.color: Atmosphere.textColor
                color: "transparent"
                z: 200

                onClicked: {
                    if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                        mediaPlayer.pause();
                    } else {
                        if (mediaPlayer.playbackState === MediaPlayer.StoppedState) {
                            mediaPlayer.source = view.filteredTracks[playlistView.currentIndex].path;
                        } else mediaPlayer.play();
                    }
                }
            }
            
            CutieButton {
                id: miniNext
                y: 10
                width: 45
                height: 50
                anchors.rightMargin: 10
                anchors.right: parent.right
                icon.name: "media-skip-forward-symbolic"
                icon.color: Atmosphere.textColor
                color: "transparent"
                z: 200

                onClicked: {
                    if (playlistView.currentIndex + 1 < view.filteredTracks.length)
                        playlistView.currentIndex++;
                    else playlistView.currentIndex = 0;
                    mediaPlayer.source = view.filteredTracks[playlistView.currentIndex].path;
                }
            }
        }

        MediaPlayer {
            id: mediaPlayer

            audioOutput: AudioOutput {}

            onMediaStatusChanged: {
                if (mediaStatus == MediaPlayer.EndOfMedia) {
                    if (playlistView.currentIndex + 1 < view.filteredTracks.length)
                        playlistView.currentIndex++;
                    else playlistView.currentIndex = 0;
                    mediaPlayer.source = view.filteredTracks[playlistView.currentIndex].path;
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
                model: view.filteredTracks
                delegate: playlistDelegate
                clip: true


                header: Column {
                    width: playlistView.width
                    spacing: 5
                    bottomPadding: 15

                    CutiePageHeader {
                        id: titleM
                        title: qsTr("Music")
                        width: parent.width // Fixes the invisible text
                    }
                    
                    // Item wrapper prevents anchor conflicts inside the Column
                    Item {
                        width: parent.width
                        height: searchField.height
                        
                        CutieTextField {
                            id: searchField
                            placeholderText: qsTr("Search...")
                            width: parent.width - 30
                        anchors.horizontalCenter: parent.horizontalCenter

                            onAccepted: view.searchQuery = text
                        }
                    }
                }
                
                footer: Item {
                    height: miniControls.height
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