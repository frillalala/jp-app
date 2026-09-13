// lib/models/item_tier.dart
enum ItemTier { learning, bronze, silver, gold, platinum }

const tierIntervals = <ItemTier, Duration?>{
  ItemTier.learning: Duration.zero, // always due
  ItemTier.bronze: Duration(hours: 48),
  ItemTier.silver: Duration(days: 7),
  ItemTier.gold: Duration(days: 14),
  ItemTier.platinum: null, // never due again
};

// Rounds needed to advance FROM this tier to the next one.
const tierAdvanceThreshold = <ItemTier, int>{
  ItemTier.learning: 5, // learning -> bronze needs 5 correct rounds
  ItemTier.bronze: 3,   // bronze -> silver needs 3
  ItemTier.silver: 3,   // silver -> gold needs 3
  ItemTier.gold: 3,     // gold -> platinum needs 3
  // platinum has no next tier
};