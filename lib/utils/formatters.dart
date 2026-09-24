String formatNaira(int kobo, {bool trimWholeKobo = false}) {
  final negative = kobo < 0;
  final abs = kobo.abs();
  final naira = abs ~/ 100;
  final rest = abs % 100;
  final digits = naira.toString();
  final grouped = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) grouped.write(',');
    grouped.write(digits[i]);
  }
  final decimals = trimWholeKobo && rest == 0
      ? ''
      : '.${rest.toString().padLeft(2, '0')}';
  return '${negative ? '-' : ''}N$grouped$decimals';
}
String formatDuration(num hours) {
  final h = hours.round();
  if (h < 48) return '$h ${h == 1 ? 'hour' : 'hours'}';
  final days = (h / 24).round();
  return '$days days';
}
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
String formatRelativeTime(DateTime time, {DateTime? now}) {
  final ref = now ?? DateTime.now();
  final diff = ref.difference(time);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${time.day} ${_months[time.month - 1]}';
}
