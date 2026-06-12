import 'dart:math';

class Koan {
  const Koan({
    required this.ruby,
    required this.character,
    required this.description,
  });

  final String ruby;
  final String character;
  final String description;
}

const _koans = [
  Koan(
    ruby: 'むじ',
    character: '無',
    description: '答えを出そうとしなくていい。ただ「無」という言葉を胸に、坐ってみてください。',
  ),
  Koan(
    ruby: 'せきしゅのこえ',
    character: '隻手の声',
    description:
        '両手を合わせれば音がする。では、片手だけの音とは何か。答えを探さず、その問いとともに静かに坐ってみてください。',
  ),
  Koan(
    ruby: 'ふぼみしょういぜんのほんらいのめんもく',
    character: '父母未生以前の本来の面目',
    description:
        'あなたの本来の姿とは何か。記憶をたどらなくていい。その問いとともに静かに坐ってみてください。',
  ),
  Koan(
    ruby: 'ていぜんのはくじゅし',
    character: '庭前の柏樹子',
    description: '謎かけではありません。この言葉を胸に置いたまま、坐ってみてください。',
  ),
  Koan(
    ruby: 'まさんきん',
    character: '麻三斤',
    description: '意味を探さなくていい。この言葉とともに、坐ってみてください。',
  ),
];

Koan randomKoan() => _koans[Random().nextInt(_koans.length)];
