/// Types of AI agents that can be created
enum AgentType {
  chat('Chat/Conversational', 'For chatbots and conversation agents',
      'openai-chat'),
  audio('Audio Processing', 'Transcription, TTS, audio analysis', 'form-data'),
  image('Image Generation', 'DALL-E, Stable Diffusion, FLUX', 'text-to-image'),
  data('Data/Analysis', 'Custom APIs, blockchain analysis', 'custom-json'),
  video('Video Processing', 'Video generation and analysis', 'custom-json');

  const AgentType(this.label, this.description, this.defaultRequestFormat);

  final String label;
  final String description;
  final String defaultRequestFormat;

  String get value => name;
}

/// Request formats for different agent types
enum RequestFormat {
  openaiChat('openai-chat', 'OpenAI Chat Completion API'),
  simpleChat('simple-chat', 'Simple JSON chat format'),
  formData('form-data', 'Multipart form data (for files)'),
  customJson('custom-json', 'Custom JSON body'),
  textToImage('text-to-image', 'Text-to-image generation');

  const RequestFormat(this.value, this.label);

  final String value;
  final String label;
}

/// Response formats
enum ResponseFormat {
  openaiChat('openai-chat', 'OpenAI Chat format'),
  simpleText('simple-text', 'Plain text or simple JSON'),
  json('json', 'Raw JSON response');

  const ResponseFormat(this.value, this.label);

  final String value;
  final String label;
}

/// Agent categories
enum AgentCategory {
  chat('Chat'),
  audio('Audio'),
  image('Image'),
  video('Video'),
  data('Data'),
  analysis('Analysis'),
  trading('Trading'),
  research('Research'),
  automation('Automation'),
  crypto('Crypto'),
  social('Social'),
  gaming('Gaming'),
  finance('Finance'),
  other('Other');

  const AgentCategory(this.label);

  final String label;

  String get value => name;
}

/// Interface types for agent interaction
enum InterfaceType {
  chat('chat', 'Chat-style conversation'),
  singleQuery('single-query', 'Single query/response'),
  data('data', 'Data API endpoint');

  const InterfaceType(this.value, this.label);

  final String value;
  final String label;
}
