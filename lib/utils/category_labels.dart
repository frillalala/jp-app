const List<String> categoryOrder = [
  'self_introduction',
  'study',
  'work',
  'friend',
  'todays_meal',
  'hobby',
  'shopping',
  'holiday',
  'living',
  'health',
];

const Map<String, String> categoryLabels = {
  'self_introduction': 'Self Introduction',
  'study': 'Study',
  'work': 'Work',
  'friend': 'Friend',
  'todays_meal': "Today's Meal",
  'hobby': 'Hobby',
  'shopping': 'Shopping',
  'holiday': 'Holiday',
  'living': 'Living',
  'health': 'Health',
};

String displayCategory(String rawCategory) {
  return categoryLabels[rawCategory] ?? rawCategory;
}