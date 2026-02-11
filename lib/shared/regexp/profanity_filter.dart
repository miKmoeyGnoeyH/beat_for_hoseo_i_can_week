// TODO: 비속어필터는 추가로 업데이트 해야됨
/// 비속어필터. 비속어가 있으면 hasMatch
const String rPrefix = r'[개갸씹좆]';
const String rSib = r'[씹]+';
const String rSibal = r'[시씨씹씌슈쓔쉬쉽쒸쓉]([a-zA-Z0-9ㄱ-ㅎ가-힣]*)[바발벌빠빡빨뻘파팔펄창]';
const String rByeonshin = r'[병븅빙볍븁빕뼝쁑삥뱡]([a-zA-Z0-9ㄱ-ㅎ가-힣]*)[신싄시씐쉰쒼슨]';
const String rSaeggi = r'(새끼|색히|샛기|색갸|샛갸|색햐|색기)+';
const String rJot = r'[좆]+';
const String rJotbap = r'[조좋좆좃쪼쫗쫒쫏줘줳줮줫쭤쭿쭺쭷찌자잫잦잣쥬즇쥿즂쥰좌좐좢좟좧]([a-zA-Z0-9ㄱ-ㅎ가-힣]*)([바밥밮빠빱빺바밯빻창]+|(같은|가튼|그튼|같네|같다|가따|가타|가테|가태)+)';
const String rJonna = r'[조좆좃줘줳줮줫쭤쭿쭺쭷잫잦잣쥬즇쥿즂준쥰존죤좌좐좢좟좧]([a-zA-Z0-9ㄱ-ㅎ가-힣]*)[나니내네]';
const String rGochu = r'[고꼬곳곧곶곷곹]([a-zA-Z0-9ㄱ-ㅎ가-힣]*)[추츄튜휴]';
const String rAmAb = r'[엄앰앱엠엡]([a-zA-Z0-9ㄱ-ㅎ가-힣]*)[업없뒤창]';
const String rAmi = r'[어애에]([a-zA-Z0-9ㄱ-ㅎ가-힣]*)[미]';
const String rAbi = r'[아애에]([a-zA-Z0-9ㄱ-ㅎ가-힣]*)[비]';
const String rSex = r'[섹섻색샋]([a-zA-Z0-9ㄱ-ㅎ가-힣]*)[스]';
const String rJazi = r'[자잠쟘쥬]([a-zA-Z0-9ㄱ-ㅎ가-힣]*)[지]';
const String rBozi = r'[보뷰]([a-zA-Z0-9ㄱ-ㅎ가-힣]*)[지]';
const String rOthers = r'()';
const String rSuffix = r'(같은|가튼|그튼|같네|같다|가따|가타|가테|가태|놈|넘|럼|람|년|련)';

final RegExp profanityFilter = RegExp('$rPrefix*($rSib|$rSaeggi|$rJot|$rGochu|$rSibal|$rByeonshin|$rJotbap|$rJonna|$rAmAb|$rAmi|$rAbi|$rSex|$rJazi|$rBozi$rOthers)+$rSuffix*');