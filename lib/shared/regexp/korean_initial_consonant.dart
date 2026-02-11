/// 한글 자모
final koreanInitialConsonantRegExp = RegExp(
  r'[\u1100-\u11FF\u3130-\u318F\uA960-\uA97F\uD7B0-\uD7FF'
  r'\u00B7\u30FB\u2027\u2219]',
  unicode: true,
);