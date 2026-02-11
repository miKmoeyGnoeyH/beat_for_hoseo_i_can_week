/// 한국 이름 형식
final RegExp koreanNameRegExp = RegExp(
    r'^(?=.{1,30}$)(?!.*[\u1100-\u11FF\u3130-\u318F])(?!.*[\u00B7\u30FB])(?:[A-Za-z\uAC00-\uD7A3]+(?:[ -][A-Za-z\uAC00-\uD7A3]+)*)$');