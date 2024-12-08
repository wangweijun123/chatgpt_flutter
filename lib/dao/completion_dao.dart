import 'package:chat_message/models/message_model.dart';
import 'package:chatgpt_flutter/util/conversation_context_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:openai_flutter/core/ai_completions.dart';
import 'package:openai_flutter/utils/ai_logger.dart';

class CompletionDao {
  final IConversationContext conversationContextHelper =
      ConversationContextHelper();

  ///初始化会话上下文
  CompletionDao({List<MessageModel>? messages}) {
    MessageModel? question, answer;
    messages?.forEach((model) {
      //sender为提问者，receiver为ChatGPT
      if (model.ownerType == OwnerType.sender) {
        question = model;
      } else {
        answer = model;
      }
      if (question != null && answer != null) {
        conversationContextHelper
            .add(ConversationModel(question!.content, answer!.content));
        question = answer = null;
      }
    });
    AILogger.log(
        'init finish,prompt is ${conversationContextHelper.getPromptContext("")}');
  }

  ///和ChatGPT进行会话
  Future<String?> createCompletions({required String prompt}) async {
    var fullPrompt = conversationContextHelper.getPromptContext(prompt);
    debugPrint('fullPrompt:$fullPrompt');
    var response =
        await AICompletion().createChat(prompt: fullPrompt, maxTokens: 1000);
    var choices = response.choices?.first;
    var content = choices?.message?.content;
    debugPrint('content:$content');
    if (content != null) {
      var list = content.split('A:'); //过滤掉不想展示的字符
      content = list.length > 1 ? list[1] : content;
      content = content.replaceFirst("\n\n", ""); //过滤掉开始的换行
      conversationContextHelper.add(ConversationModel(prompt, content));
    }
    return content;
  }
}
