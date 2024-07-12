// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:rxdart/rxdart.dart';

// import '../../chatScreen.dart';
// import '../../common.dart';
// import '../globals.dart';

// class AudioBubble extends StatefulWidget {
//   const AudioBubble({Key? key, required this.currIndex}) : super(key: key);

//   final int currIndex;

//   @override
//   State<AudioBubble> createState() => _AudioBubbleState();
// }

// class _AudioBubbleState extends State<AudioBubble> {
//   //AudioPlayer player = AudioPlayer();
//   //Duration? duration, totalduration;
//   String msgid = "";
//   @override
//   void initState() {
//     super.initState();
//     msgid = chatMessageList[widget.currIndex].messageId!;
//     print("key===${widget.key}");

//     // setAudio();
//     /* player.setFilePath(widget.filepath).then((value) {
//       setState(() {
//         duration = value;
//       });
//     }); */
//   }

//   @override
//   Widget build(BuildContext context) {
//     return audioWidget(chatMessageList[widget.currIndex].messageId!,
//         chatMessageList[widget.currIndex].audioPlayer!);
//     /*
//     return Container(
//       height: 45,
//       width: MediaQuery.of(context).size.width / 1.5,
//       padding: const EdgeInsets.only(left: 12, right: 18),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(Globals.borderRadius - 10),
//         color: Colors.grey.withOpacity(0.2),
//         //color: Colors.black,
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           StreamBuilder<PlayerState>(
//             stream: player.playerStateStream,
//             builder: (context, snapshot) {
//               final playerState = snapshot.data;
//               final processingState = playerState?.processingState;
//               final playing = playerState?.playing;
            

//               if (processingState == ProcessingState.loading ||
//                   processingState == ProcessingState.buffering) {
//                 return GestureDetector(
//                   child: const Icon(Icons.play_arrow),
//                   onTap: () {
                  
//                     player.play();
//                   },
//                 );
//               } else if (playing != true) {
//                 return GestureDetector(
//                   child: const Icon(Icons.play_arrow),
//                   onTap: player.play,
//                 );
//               } else if (processingState != ProcessingState.completed) {
//                 return GestureDetector(
//                   child: const Icon(Icons.pause),
//                   onTap: player.pause,
//                 );
//               } else {
//                 return GestureDetector(
//                   child: const Icon(Icons.replay),
//                   onTap: () {
//                     player.seek(Duration.zero);
//                   },
//                 );
//               }
//             },
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: StreamBuilder<Duration>(
//               stream: player.positionStream,
//               builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                   return Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const SizedBox(height: 4),
//                       LinearProgressIndicator(
//                         value: snapshot.data!.inMilliseconds /
//                             (duration?.inMilliseconds ?? 1),
//                         backgroundColor: Colors.grey,
//                         color: ColorsRes.appcolor,
//                       ),
//                       const SizedBox(height: 6),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             prettyDuration(snapshot.data! == Duration.zero
//                                 ? duration ?? Duration.zero
//                                 : snapshot.data!),
//                             style: const TextStyle(
//                               fontSize: 10,
//                               color: Colors.grey,
//                             ),
//                           ),
//                           Text(
//                             prettyDuration(totalduration ?? Duration.zero),
//                             style: const TextStyle(
//                               fontSize: 10,
//                               color: Colors.grey,
//                             ),
//                           ),
//                           /*const Text(
//                             "M4A",
//                             style: TextStyle(
//                               fontSize: 10,
//                               color: Colors.grey,
//                             ),
//                           ),*/
//                         ],
//                       ),
                   
//                     ],
//                   );
//                 } else {
//                   return const LinearProgressIndicator();
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//  */
//   }
// /* 
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           SizedBox(width: MediaQuery.of(context).size.width * 0.4),
//           Expanded(
//             child: Container(
//               height: 45,
//               padding: const EdgeInsets.only(left: 12, right: 18),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(Globals.borderRadius - 10),
//                 color: Colors.white,
//                 //color: Colors.black,
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       StreamBuilder<PlayerState>(
//                         stream: player.playerStateStream,
//                         builder: (context, snapshot) {
//                           final playerState = snapshot.data;
//                           final processingState = playerState?.processingState;
//                           final playing = playerState?.playing;
//                           if (processingState == ProcessingState.loading ||
//                               processingState == ProcessingState.buffering) {
//                             return GestureDetector(
//                               child: const Icon(Icons.play_arrow),
//                               onTap: player.play,
//                             );
//                           } else if (playing != true) {
//                             return GestureDetector(
//                               child: const Icon(Icons.play_arrow),
//                               onTap: player.play,
//                             );
//                           } else if (processingState !=
//                               ProcessingState.completed) {
//                             return GestureDetector(
//                               child: const Icon(Icons.pause),
//                               onTap: player.pause,
//                             );
//                           } else {
//                             return GestureDetector(
//                               child: const Icon(Icons.replay),
//                               onTap: () {
//                                 player.seek(Duration.zero);
//                               },
//                             );
//                           }
//                         },
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: StreamBuilder<Duration>(
//                           stream: player.positionStream,
//                           builder: (context, snapshot) {
//                             if (snapshot.hasData) {
//                               return Column(
//                                 children: [
//                                   const SizedBox(height: 4),
//                                   LinearProgressIndicator(
//                                     value: snapshot.data!.inMilliseconds /
//                                         (duration?.inMilliseconds ?? 1),
//                                   ),
//                                   const SizedBox(height: 6),
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         prettyDuration(
//                                             snapshot.data! == Duration.zero
//                                                 ? duration ?? Duration.zero
//                                                 : snapshot.data!),
//                                         style: const TextStyle(
//                                           fontSize: 10,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                       const Text(
//                                         "M4A",
//                                         style: TextStyle(
//                                           fontSize: 10,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               );
//                             } else {
//                               return const LinearProgressIndicator();
//                             }
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   } */

//   String prettyDuration(Duration d) {
//     var min = d.inMinutes < 10 ? "0${d.inMinutes}" : d.inMinutes.toString();
//     var sec = d.inSeconds < 10 ? "0${d.inSeconds}" : d.inSeconds.toString();
//     return "$min:$sec";
//   }

//   audioWidget(String msgid, AudioPlayer? player) {
//     // print("map-$msgid-$audioplaysermap");
//     Map? map = audioplaysermap[msgid];
//     //AudioPlayer player = map!["player"];
//     if (player == null) return const SizedBox.shrink();
//     return Container(
//       //height: 50,
//       width: MediaQuery.of(context).size.width / 1.5,
//       padding: const EdgeInsets.only(left: 8, right: 18),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(Globals.borderRadius - 10),
//         color: Colors.grey.withOpacity(0.2),
//         //color: Colors.black,
//       ),
//       child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
//         StreamBuilder<PlayerState>(
//           stream: player.playerStateStream,
//           builder: (context, snapshot) {
//             final playerState = snapshot.data;
//             final processingState = playerState?.processingState;
//             bool playing = playerState?.playing ?? false;
//             print("state---$playing==$processingState");

//             if (processingState == ProcessingState.completed &&
//                 player.position != Duration.zero) {
//               player.seek(Duration.zero);
//               player.pause();
//             }

//             if (processingState == ProcessingState.loading ||
//                 processingState == ProcessingState.buffering) {
//               return IconButton(
//                 icon: const Icon(Icons.play_arrow),
//                 iconSize: 30.0,
//                 onPressed: () {},
//               );
//             } else if (!playing ||
//                 processingState == ProcessingState.completed) {
//               return IconButton(
//                 icon: const Icon(Icons.play_arrow),
//                 iconSize: 30.0,
//                 onPressed: () {
//                   /* if (currPlayingAudioId != msgid &&
//                       currAudioplayer != null &&
//                       currAudioplayer!.playing) {
//                     currAudioplayer!.stop();
//                   } */
//                   if (currPlayingAudioId != msgid &&
//                       audioplaysermap.containsKey(currPlayingAudioId) &&
//                       audioplaysermap[currPlayingAudioId]!["player"] != null &&
//                       audioplaysermap[currPlayingAudioId]!["player"].playing) {
//                     audioplaysermap[currPlayingAudioId]!["player"].pause();
//                   }
//                   print("click===${player.duration}");
//                   if (processingState == ProcessingState.completed &&
//                       player.position != Duration.zero) {
//                     player.seek(Duration.zero);
//                   }
//                   player.play();
//                   print("click===**${player.playing}");
//                   currPlayingAudioId = msgid;
//                   currAudioplayer = player;
//                 },
//               );
//             } else if (processingState != ProcessingState.completed) {
//               return IconButton(
//                 icon: const Icon(Icons.pause),
//                 iconSize: 30.0,
//                 onPressed: player.pause,
//               );
//             } else {
//               return IconButton(
//                 icon: const Icon(Icons.replay),
//                 iconSize: 64.0,
//                 onPressed: () => player.seek(Duration.zero),
//               );
//             }
//           },
//         ),
//         Expanded(
//           child: StreamBuilder<PositionData>(
//             //stream: _positionDataStream,
//             stream: getPositionStream(player),
//             builder: (context, snapshot) {
//               final positionData = snapshot.data;
//               return SeekBar(
//                 duration: positionData?.duration ?? Duration.zero,
//                 position: positionData?.position ?? Duration.zero,
//                 bufferedPosition:
//                     positionData?.bufferedPosition ?? Duration.zero,
//                 onChangeEnd: player.seek,
//               );
//             },
//           ),
//         )
//       ]),
//     );
//   }

//   Stream<PositionData> getPositionStream(AudioPlayer player) {
//     Stream<PositionData> data =
//         Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
//             player.positionStream,
//             player.bufferedPositionStream,
//             player.durationStream,
//             (position, bufferedPosition, duration) => PositionData(
//                 position, bufferedPosition, duration ?? Duration.zero));
//     return data;
//   }
// }
// /*

//   audioWidget(String msgid, AudioPlayer? player) {
//     print("map-$msgid-$audioplaysermap");
//     Map? map = audioplaysermap[msgid];
//     //AudioPlayer player = map!["player"];
//     if (player == null) return const SizedBox.shrink();
//     return Row(mainAxisSize: MainAxisSize.min, children: [
//       CircleAvatar(
//         radius: 30,
//         child: Column(mainAxisSize: MainAxisSize.min, children: [
//           const Icon(Icons.headphones),
//           Text(
//             Constant.getDurationFormat(player.duration!),
//             style:
//                 Theme.of(context).textTheme.caption!.apply(color: Colors.white),
//           )
//         ]),
//       ),
//       StreamBuilder<PlayerState>(
//         stream: player.playerStateStream,
//         builder: (context, snapshot) {
//           final playerState = snapshot.data;
//           final processingState = playerState?.processingState;
//           bool playing = playerState?.playing ?? false;
//           print("state---$playing==$processingState");

//           if (processingState == ProcessingState.completed &&
//               player.position != Duration.zero) {
//             player.seek(Duration.zero);
//             player.pause();
//           }

//           if (processingState == ProcessingState.loading ||
//               processingState == ProcessingState.buffering) {
//             return Container(
//               margin: const EdgeInsets.all(8.0),
//               width: 30.0,
//               height: 30.0,
//               child: const CircularProgressIndicator(),
//             );
//           } else if (!playing || processingState == ProcessingState.completed) {
//             return IconButton(
//               icon: const Icon(Icons.play_arrow),
//               iconSize: 30.0,
//               onPressed: () {
//                 /* if (currPlayingAudioId != msgid &&
//                     currAudioplayer != null &&
//                     currAudioplayer!.playing) {
//                   currAudioplayer!.stop();
//                 } */
//                 if (currPlayingAudioId != msgid &&
//                     audioplaysermap.containsKey(currPlayingAudioId) &&
//                     audioplaysermap[currPlayingAudioId]!["player"] != null &&
//                     audioplaysermap[currPlayingAudioId]!["player"].playing) {
//                   audioplaysermap[currPlayingAudioId]!["player"].pause();
//                 }
//                 print("click===${player.duration}");
//                 if (processingState == ProcessingState.completed &&
//                     player.position != Duration.zero) {
//                   player.seek(Duration.zero);
//                 }
//                 player.play();
//                 print("click===**${player.playing}");
//                 currPlayingAudioId = msgid;
//                 currAudioplayer = player;
//               },
//             );
//           } else if (processingState != ProcessingState.completed) {
//             return IconButton(
//               icon: const Icon(Icons.pause),
//               iconSize: 30.0,
//               onPressed: player.pause,
//             );
//           } else {
//             return IconButton(
//               icon: const Icon(Icons.replay),
//               iconSize: 64.0,
//               onPressed: () => player.seek(Duration.zero),
//             );
//           }
//         },
//       ),
//       Expanded(
//         child: StreamBuilder<PositionData>(
//           //stream: _positionDataStream,
//           stream: getPositionStream(player),
//           builder: (context, snapshot) {
//             final positionData = snapshot.data;
//             return SeekBar(
//               duration: positionData?.duration ?? Duration.zero,
//               position: positionData?.position ?? Duration.zero,
//               bufferedPosition: positionData?.bufferedPosition ?? Duration.zero,
//               onChangeEnd: player.seek,
//             );
//           },
//         ),
//       )
//     ]);
//   }

//   Stream<PositionData> getPositionStream(AudioPlayer player) {
//     Stream<PositionData> data =
//         Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
//             player.positionStream,
//             player.bufferedPositionStream,
//             player.durationStream,
//             (position, bufferedPosition, duration) => PositionData(
//                 position, bufferedPosition, duration ?? Duration.zero));
//     return data;
//   }
// */