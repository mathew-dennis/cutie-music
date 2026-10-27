import Cutie
import QtMultimedia
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Effects
import QtQuick.Window

// Authors: Alexey T. (vin4ter), Erik Inkinen
// Contributors: Mathew Dennis
CutieWindow {
    id: view
    // Set false to hide the benchmark HUD and stop its frame sampler.
    property bool showFrameStats: true
    property bool playedStatus: false
    property int value: 0
    property bool btnPlayslate: false
    property int toMove: 0
    property int colPlaylist: 0
    property string searchQuery: ""
    property var filteredTrackList: cutieMusic.trackList.filter(function(item) {
        if (!view.searchQuery) return true;
        var q = view.searchQuery.toLowerCase();
        return item.title.toLowerCase().includes(q) ||
               item.artist.toLowerCase().includes(q);
    })

    width: 400
    height: 800
    visible: true
    title: qsTr("Music")

    Component.onCompleted: {
         if (audioFileArgument && audioFileArgument.trim().length > 4) {
            cutieMusic.addExternalTrack(audioFileArgument);
            mediaPlayer.source = cutieMusic.trackList[0].path;
        }
    }

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

            MultiEffect {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: view.height
                source: playlistView
                blurEnabled: true
                blur: 1.0
                blurMax: 40
            }

            Image {
                id: miniCover
                y: 10
                width: 50
                height: 50
                anchors.leftMargin: 10
                anchors.left: parent.left
                fillMode: Image.PreserveAspectCrop
                source: view.filteredTrackList[playlistView.currentIndex].path.toString().replace("file:///", "image://cover/")
            }

            CutieLabel {
                anchors.top: parent.top
                anchors.topMargin: 14
                anchors.leftMargin: 15
                anchors.left: miniCover.right
                anchors.rightMargin: 10
                anchors.right: miniPlay.left
                text: view.filteredTrackList[playlistView.currentIndex].title
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
                text: view.filteredTrackList[playlistView.currentIndex].artist
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
                            mediaPlayer.source = view.filteredTrackList[playlistView.currentIndex].path;
                        } else mediaPlayer.play();
                    }
                }
            }
            
            CutieButton {
                id: miniNext
                y: 10
                width: 45
                height: 50
                anchors.rightMargin: 5
                anchors.right: parent.right
                icon.name: "media-skip-forward-symbolic"
                icon.color: Atmosphere.textColor
                color: "transparent"
                z: 200

                onClicked: {
                    if (playlistView.currentIndex + 1 < view.filteredTrackList.length)
                        playlistView.currentIndex++;
                    else playlistView.currentIndex = 0;
                    mediaPlayer.source = view.filteredTrackList[playlistView.currentIndex].path;
                }
            }
        }

        MediaPlayer {
            id: mediaPlayer

            audioOutput: AudioOutput {}

            onMediaStatusChanged: {
                if (mediaStatus == MediaPlayer.EndOfMedia) {
                    if (playlistView.currentIndex + 1 < view.filteredTrackList.length)
                        playlistView.currentIndex++;
                    else playlistView.currentIndex = 0;
                    mediaPlayer.source = view.filteredTrackList[playlistView.currentIndex].path;
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
                model: view.filteredTrackList
                delegate: playlistDelegate
                cacheBuffer: 500
                clip: true


                header: Column {
                    width: playlistView.width
                    height: 120
                    spacing: 10

                    CutiePageHeader {
                    id: titleM
                    title: qsTr("Music")
                        width: parent.width // Fixes the invisible text
                    }
                      
                    CutieSearchBox {
                            id: searchField
                            placeholderText: qsTr("Search songs...")
                            width: parent.width - 30
                            anchors.horizontalCenter: parent.horizontalCenter
                            onAccepted: view.searchQuery = text
                    }

                }
                footer: Item {
                    height: miniControls.height
                }
            }
        }

        // Small, opt-in benchmark HUD. FrameAnimation follows Qt Quick's
        // rendered animation-frame updates; the label itself refreshes once
        // per second to keep the measurement overhead low.
        Rectangle {
            id: frameStatsOverlay
            visible: view.showFrameStats
            z: 10000
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 8
            implicitWidth: frameStatsLabel.implicitWidth + 16
            implicitHeight: frameStatsLabel.implicitHeight + 10
            radius: 6
            color: "#dd171717"

            FrameAnimation {
                id: frameCounter
                running: view.showFrameStats && view.visible && playlistView.moving

                onRunningChanged: {
                    if (running) {
                        reset()
                        frameStatsSampler.beginScroll()
                    } else if (elapsedTime > 0 && currentFrame > 0) {
                        frameStatsSampler.finishScroll(currentFrame, elapsedTime)
                    }
                }
            }

            Timer {
                id: frameStatsSampler
                property int previousFrameCount: 0
                property real previousElapsedTime: 0
                property real framesPerSecond: 0
                property int totalFrames: 0
                property real averageFrameTimeMs: 0
                property bool hasSample: false

                interval: 1000
                repeat: true
                running: frameCounter.running

                function logStats(eventName, durationMs, fps, frameTimeMs, frames, total) {
                    console.info("CUTIE_FRAME_STATS " + JSON.stringify({
                        event: eventName,
                        timestamp_ms: Date.now(),
                        duration_ms: Math.round(durationMs),
                        fps: Math.round(fps * 10) / 10,
                        frame_ms: Math.round(frameTimeMs * 10) / 10,
                        frames: frames,
                        total_frames: total,
                        scroll_y: Math.round(playlistView.contentY),
                        item_count: playlistView.count,
                        current_index: playlistView.currentIndex
                    }))
                }

                function beginScroll() {
                    previousFrameCount = frameCounter.currentFrame
                    previousElapsedTime = frameCounter.elapsedTime
                    framesPerSecond = 0
                    totalFrames = frameCounter.currentFrame
                    averageFrameTimeMs = 0
                    hasSample = false
                }

                function finishScroll(frameCount, elapsedSeconds) {
                    var fps = elapsedSeconds > 0 ? frameCount / elapsedSeconds : 0
                    var frameTimeMs = frameCount > 0
                        ? elapsedSeconds * 1000 / frameCount : 0
                    totalFrames = frameCount
                    framesPerSecond = fps
                    averageFrameTimeMs = frameTimeMs
                    hasSample = frameCount > 0
                    logStats("scroll_end", elapsedSeconds * 1000, fps,
                             averageFrameTimeMs, frameCount, frameCount)
                }

                onTriggered: {
                    var currentFrameCount = frameCounter.currentFrame
                    var currentElapsedTime = frameCounter.elapsedTime
                    var frameDelta = currentFrameCount - previousFrameCount
                    var elapsedDelta = currentElapsedTime - previousElapsedTime
                    if (frameDelta <= 0 || elapsedDelta <= 0)
                        return

                    framesPerSecond = frameDelta / elapsedDelta
                    previousFrameCount = currentFrameCount
                    previousElapsedTime = currentElapsedTime
                    totalFrames = currentFrameCount
                    averageFrameTimeMs = elapsedDelta * 1000 / frameDelta
                    hasSample = true
                    logStats("scroll_sample", elapsedDelta * 1000,
                             framesPerSecond, averageFrameTimeMs,
                             frameDelta, totalFrames)
                }
            }

            Text {
                id: frameStatsLabel
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: 12
                text: frameStatsSampler.hasSample
                    ? qsTr("%1 FPS  ·  %2 ms  ·  %3 frames")
                        .arg(frameStatsSampler.framesPerSecond.toFixed(0))
                        .arg(frameStatsSampler.averageFrameTimeMs.toFixed(1))
                        .arg(frameStatsSampler.totalFrames)
                    : qsTr("Scroll to measure")
            }
        }

        Component {
            id: playlistDelegate

            CutieListItem {
                highlighted: playlistView.currentIndex == index
                icon.source: modelData.path.toString().replace("file:///", "image://cover/")
                icon.width: 20
                icon.height: 20
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
