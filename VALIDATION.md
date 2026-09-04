# Validation: v2.5.1 five-font personal build

Time font selector order is exactly:
Smackers -> Nautica -> Cleo -> Pincoya -> Alien -> Smackers.

Fresh-install `fontChoice` defaults to Smackers (`0`). Removed or unknown legacy font IDs, including the experimental Alien Numbers ID (`11`), normalize to Smackers.

Date and battery always use the normal secondary font resources at the selected size. No Alien date/battery resources are packaged.

Color selector order is exactly:
Black -> Red -> Orange -> Yellow -> Green -> Blue -> Purple -> Pink -> White.

Fixed display coordinates remain date center y=57, time center y=130, battery center y=203 (73 px each side). Battery is permanently in the balanced position. Time remains fixed to 24-hour HHMM with no colon.
## v2.5.2 large-text crispness
- Date and battery Tiny/Small/Normal/Large remain separate native bitmap-font resources.
- Large date and battery atlases are now 1-bit (black/white only) and imported with antialias=false to avoid soft gray fringes on the Forerunner 955 MIP display.
