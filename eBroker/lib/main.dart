import 'package:ebroker/app/register_cubits.dart';
import 'package:ebroker/data/process/language_load_process.dart';
import 'package:ebroker/ui/screens/chat/chat_audio/globals.dart';
import 'package:ebroker/ui/screens/chat_new/message_types/registerar.dart';
import 'package:ebroker/utils/Queue/queue.dart';
import 'package:flutter/material.dart';
import 'data/process/app_settings.dart';
import 'exports/main_export.dart';

/////////////////
////V-1.1.4/////
///////////////

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await processQueue();
  initApp();
}

class EntryPoint extends StatefulWidget {
  const EntryPoint({
    super.key,
  });
  @override
  EntryPointState createState() => EntryPointState();
}

class EntryPointState extends State<EntryPoint> {
  @override
  void initState() {
    super.initState();
    ChatMessageHandler.handle();
    ChatGlobals.init();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          ...RegisterCubits().register(),
        ],
        child: Builder(builder: (BuildContext context) {
          return const App();
        }));
  }
}

Future<void> processQueue() async {
  try {
    ///This is to load app settings and language setting apart from main thread to load app work more faster.
    ProcessQueue processQueue = ProcessQueue();

    ///This will start 2 isolate workers.
    await processQueue.startIsolates(2);

    ///Adding process to queue.
    Constant.appSettingTaskId =
        await processQueue.enqueueTask(AppSettingsLoadTask());

    Constant.languageTaskId =
        await processQueue.enqueueTask(LanguageLoadProcess());
//Awaiting for the result of the appSettings
    await processQueue.getResult(Constant.appSettingTaskId!);
  } catch (e) {}
}
