#!/usr/bin/env bash
# shellcheck disable=SC2154

# Based on Dungeons & Dragons 5E (5th edition)

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Sources all .sh files in $HOME/Documents/linux_docs/configs/system/bash/bashrc.d
shopt -s globstar nullglob

# shellcheck source=/dev/null
for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f "$rc" ]] && source "$rc"
done
unset rc
shopt -u globstar nullglob

# To do: fix racial traits using https://dnd5e.wikidot.com

roll_stat() {
    awk -v seed="$(date +%s%N)" '
        BEGIN {
            srand(seed)
            d1 = int(rand()*6)+1
            d2 = int(rand()*6)+1
            d3 = int(rand()*6)+1
            print d1 + d2 + d3 + 3
        }
    '
}

print_ability() {
    ability="$1"
    score="$2"
    mod="$3"

    if [ "$mod" -gt 0 ]; then
        mod_fmt="+$mod"
    else
        mod_fmt="$mod"
    fi

    green_message "$ability:" "$score  [$mod_fmt]"
}

print_racial_traits() {
    race="$1"
    case "$race" in
        "dark elf")
            printf '%s\n' \
            "Superior Darkvision" \
            "Keen Senses" \
            "Fey Ancestry" \
            "Sunlight Sensitivity" \
            "Drow Magic" \
            "Drow Weapon Training"
            ;;
        "dragonborn")
            printf '%s\n' \
            "Draconic Ancestry" \
            "Breath Weapon" \
            "Damage Resistance"
            ;;
        "forest gnome")
            printf '%s\n' \
            "Darkvision" \
            "Gnome Cunning" \
            "Natural Illusionist" \
            "Speak with Small Beasts"
            ;;
        "half-elf")
            printf '%s\n' \
            "Darkvision" \
            "Fey Ancestry" \
            "Skill Versatility" \
            "Ability Bonus"
            ;;
        "half-orc")
            printf '%s\n' \
            "Darkvision" \
            "Menacing" \
            "Relentless Endurance" \
            "Savage Attacks"
            ;;
        "high elf")
            printf '%s\n' \
            "Darkvision" \
            "Keen Senses" \
            "Fey Ancestry" \
            "Trance" \
            "Cantrip" \
            "Elf Weapon Training" \
            "Extra Language"
            ;;
        "hill dwarf")
            printf '%s\n' \
            "Darkvision" \
            "Dwarven Resilience" \
            "Dwarven Combat Training" \
            "Tool Proficiency" \
            "Stonecunning" \
            "Dwarven Toughness"
            ;;
        "human")
            printf '%s\n' \
            "Extra Language"
            ;;
        "lightfoot halfling")
            printf '%s\n' \
            "Lucky" \
            "Brave" \
            "Nimble" \
            "Naturally Stealthy"
            ;;
        "mountain dwarf")
            printf '%s\n' \
            "Darkvision" \
            "Dwarven Resilience" \
            "Dwarven Combat Training" \
            "Tool Proficiency" \
            "Stonecunning" \
            "Dwarven Armor Training"
            ;;
        "rock gnome")
            printf '%s\n' \
            "Darkvision" \
            "Gnome Cunning" \
            "Artificer's Lore" \
            "Tinker"
            ;;
        "stout halfling")
            printf '%s\n' \
            "Lucky" \
            "Brave" \
            "Nimble" \
            "Stout Resilience"
            ;;
        "tiefling")
            printf '%s\n' \
            "Darkvision" \
            "Hellish Resistance" \
            "Infernal Legacy"
            ;;
        "wood elf")
            printf '%s\n' \
            "Darkvision" \
            "Keen Senses" \
            "Fey Ancestry" \
            "Trance" \
            "Elf Weapon Training" \
            "Fleet of Foot" \
            "Mask of the Wild"
            ;;
    esac
}

str=0
dex=0
con=0
int=0
wis=0
cha=0

str_mod=0
dex_mod=0
con_mod=0
int_mod=0
wis_mod=0
cha_mod=0

speed=0
hit_die=0
hp=0

race=""
variant=""
race_uc=""
color_uc=""
size=""
class=""

green_message "Races:"
echo "Dragonborn
Dwarf
Elf
Gnome
Half-Elf
Half-Orc
Halfling
Human
Tiefling"

read -r -p "Enter race: " race

if [ -z "$race" ]; then
    red_message "Error:" "No race selected."
    exit 1
fi

race=$(printf '%s' "$race" | tr '[:upper:]' '[:lower:]')

case "$race" in
    "dwarf")
        read -r -p "Enter race variant [Hill/Mountain]: " variant
        ;;
    "elf")
        read -r -p "Enter race variant [Dark/High/Wood]: " variant
        ;;
    "gnome")
        read -r -p "Enter race variant [Forest/Rock]: " variant
        ;;
    "halfling")
        read -r -p "Enter race variant [Lightfoot/Stout]: " variant
        ;;
esac

case "$race" in
    "dwarf"|"elf"|"gnome"|"halfling")
        if [ -z "$variant" ]; then
            red_message "Error:" "No variant selected."
            exit 1
        fi
        ;;
esac

if [ -n "$variant" ]; then
    variant=$(printf '%s' "$variant" | tr '[:upper:]' '[:lower:]')
    race="${variant} ${race}"
fi

case "$race" in
    "dark elf")
        race_uc="Dark Elf"
        size="Medium"
        speed=30
        ;;
    "dragonborn")
        race_uc="Dragonborn"
        size="Medium"
        speed=30
        ;;
    "forest gnome")
        race_uc="Forest Gnome"
        size="Small"
        speed=25
        ;;
    "half-elf")
        race_uc="Half-Elf"
        size="Medium"
        speed=30
        ;;
    "half-orc")
        race_uc="Half-Orc"
        size="Medium"
        speed=30
        ;;
    "lightfoot halfling")
        race_uc="Lightfoot Halfling"
        size="Small"
        speed=25
        ;;
    "high elf")
        race_uc="High Elf"
        size="Medium"
        speed=30
        ;;
    "hill dwarf")
        race_uc="Hill Dwarf"
        size="Medium"
        speed=25
        ;;
    "human")
        race_uc="Human"
        size="Medium"
        speed=30
        ;;
    "mountain dwarf")
        race_uc="Mountain Dwarf"
        size="Medium"
        speed=25
        ;;
    "rock gnome")
        race_uc="Rock Gnome"
        size="Small"
        speed=25
        ;;
    "stout halfling")
        race_uc="Stout Halfling"
        size="Small"
        speed=25
        ;;
    "tiefling")
        race_uc="Tiefling"
        size="Medium"
        speed=30
        ;;
    "wood elf")
        race_uc="Wood Elf"
        size="Medium"
        speed=30
        ;;
    *)
        red_message "Unknown race:" "$race"
        exit 1
esac

case "$race" in
    "dragonborn")
        green_message "Dragon Colors:"
        printf '%s\n' \
        Black \
        Blue \
        Brass \
        Bronze \
        Copper \
        Gold \
        Green \
        Red \
        Silver \
        White
        read -r -p "Enter dragon color: " color

        if [ -z "$color" ]; then
            red_message "Error:" "No color selected."
            exit 1
        fi

        color=$(printf '%s' "$color" | tr '[:upper:]' '[:lower:]')

        case "$color" in
            "black")
                color_uc="Black"
                dmg_type="Acid"
                breath_weapon="5 by 30 ft line (DEX save)"
                ;;
            "blue")
                color_uc="Blue"
                dmg_type="Lightning"
                breath_weapon="5 by 30 ft line (DEX save)"
                ;;
            "brass")
                color_uc="Brass"
                dmg_type="Fire"
                breath_weapon="5 by 30 ft line (DEX save)"
                ;;
            "bronze")
                color_uc="Bronze"
                dmg_type="Lightning"
                breath_weapon="5 by 30 ft line (DEX save)"
                ;;
            "copper")
                color_uc="Copper"
                dmg_type="Acid"
                breath_weapon="5 by 30 ft line (DEX save)"
                ;;
            "gold")
                color_uc="Gold"
                dmg_type="Fire"
                breath_weapon="15 ft cone (DEX save)"
                ;;
            "green")
                color_uc="Green"
                dmg_type="Poison"
                breath_weapon="15 ft cone (CON save)"
                ;;
            "red")
                color_uc="Red"
                dmg_type="Fire"
                breath_weapon="15 ft cone (DEX save)"
                ;;
            "silver")
                color_uc="Silver"
                dmg_type="Cold"
                breath_weapon="15 ft cone (CON save)"
                ;;
            "white")
                color_uc="White"
                dmg_type="Cold"
                breath_weapon="15 ft cone (CON save)"
                ;;
            *)
                red_message "Unknown color:" "$color"
                exit 1
        esac
        ;;
esac

green_message "Classes:"
echo "Barbarian
Bard
Cleric
Druid
Fighter
Monk
Paladin
Ranger
Rogue
Sorcerer
Warlock
Wizard"
read -r -p "Enter class: " class

if [ -z "$class" ]; then
    red_message "Error:" "No class selected."
    exit 1
fi

class=$(printf '%s' "$class" | tr '[:upper:]' '[:lower:]')
class_uc=""

case "$class" in
    "barbarian")
        class_uc="Barbarian"
        hit_die=12
        primary_ability="STR"
        saves="STR, CON"
        ;;
    "bard")
        class_uc="Bard"
        hit_die=8
        primary_ability="CHA"
        saves="DEX, CHA"
        ;;
    "cleric")
        class_uc="Cleric"
        hit_die=8
        primary_ability="WIS"
        saves="WIS, CHA"
        ;;
    "druid")
        class_uc="Druid"
        hit_die=8
        primary_ability="WIS"
        saves="INT, WIS"
        ;;
    "fighter")
        class_uc="Fighter"
        hit_die=10
        primary_ability="STR or DEX"
        saves="STR, CON"
        ;;
    "monk")
        class_uc="Monk"
        hit_die=8
        primary_ability="DEX and WIS"
        saves="STR, DEX"
        ;;
    "paladin")
        class_uc="Paladin"
        hit_die=10
        primary_ability="STR and CHA"
        saves="WIS, CHA"
        ;;
    "ranger")
        class_uc="Ranger"
        hit_die=10
        primary_ability="DEX and WIS"
        saves="STR, DEX"
        ;;
    "rogue")
        class_uc="Rogue"
        hit_die=8
        primary_ability="DEX"
        saves="DEX, INT"
        ;;
    "sorcerer")
        class_uc="Sorcerer"
        hit_die=6
        primary_ability="CHA"
        saves="CON, CHA"
        ;;
    "warlock")
        class_uc="Warlock"
        hit_die=8
        primary_ability="CHA"
        saves="WIS, CHA"
        ;;
    "wizard")
        class_uc="Wizard"
        hit_die=6
        primary_ability="INT"
        saves="INT, WIS"
        ;;
    *)
        red_message "Unknown class:" "$class"
        exit 1
esac

green_message "Race:" "$race_uc"
green_message "Size:" "$size"
green_message "Speed:" "$speed ft"
green_message "Racial Traits:"
print_racial_traits "$race"

case "$race" in
    "dragonborn")
        green_message "Dragon Color:" "$color_uc"
        green_message "Damage Type:" "$dmg_type"
        green_message "Breath Weapon:" "$breath_weapon"
        ;;
esac

green_message "Class:" "$class_uc"
green_message "Hit Die:" "d$hit_die"
green_message "Primary Ability:" "$primary_ability"
green_message "Saves:" "$saves"

for ability in str dex con int wis cha; do
    value=$(roll_stat)

    case "$ability" in
        "str") str="$value" ;;
        "dex") dex="$value" ;;
        "con") con="$value" ;;
        "int") int="$value" ;;
        "wis") wis="$value" ;;
        "cha") cha="$value" ;;
    esac
done

case "$race" in
    "dark elf")
        dex=$(( dex + 2 ))
        cha=$(( cha + 1 ))
        ;;
    "dragonborn")
        str=$(( str + 2 ))
        cha=$(( cha + 1 ))
        ;;
    "forest gnome")
        dex=$(( dex + 1 ))
        int=$(( int + 2 ))
        ;;
    "half-elf")
        cha=$(( cha + 2 ))
        ;;
    "half-orc")
        str=$(( str + 2 ))
        con=$(( con + 1 ))
        ;;
    "lightfoot halfling")
        dex=$(( dex + 2 ))
        cha=$(( cha + 1 ))
        ;;
    "high elf")
        dex=$(( dex + 2 ))
        int=$(( int + 1 ))
        ;;
    "hill dwarf")
        con=$(( con + 2 ))
        wis=$(( wis + 1 ))
        ;;
    "human")
        str=$(( str + 1 ))
        dex=$(( dex + 1 ))
        con=$(( con + 1 ))
        int=$(( int + 1 ))
        wis=$(( wis + 1 ))
        cha=$(( cha + 1 ))
        ;;
    "mountain dwarf")
        str=$(( str + 2 ))
        con=$(( con + 2 ))
        ;;
    "rock gnome")
        con=$(( con + 1 ))
        int=$(( int + 2 ))
        ;;
    "stout halfling")
        dex=$(( dex + 2 ))
        con=$(( con + 1 ))
        ;;
    "tiefling")
        int=$(( int + 1 ))
        cha=$(( cha + 2 ))
        ;;
    "wood elf")
        dex=$(( dex + 2 ))
        wis=$(( wis + 1 ))
        ;;
esac

case "$race" in
    "half-elf")
        read -r -p "Enter first ability to receive +1 bonus [str/dex/con/int/wis/cha]: " bonus1
        read -r -p "Enter second ability to receive +1 bonus [str/dex/con/int/wis/cha]: " bonus2

        for bonus in "$bonus1" "$bonus2"; do
            if [ -z "$bonus" ]; then
                red_message "Error" "No ability selected."
                exit 1
            fi

            if [ "$bonus1" = "$bonus2" ]; then
                red_message "Error:" "You must choose two different abilities."
                exit 1
            fi

            bonus=$(printf '%s' "$bonus" | tr '[:upper:]' '[:lower:]')

            case "$bonus" in
                "str") str=$(( str + 1 )) ;;
                "dex") dex=$(( dex + 1 )) ;;
                "con") con=$(( con + 1 )) ;;
                "int") int=$(( int + 1 )) ;;
                "wis") wis=$(( wis + 1 )) ;;
                "cha") cha=$(( cha + 1 )) ;;
                *)
                    red_message "Error:" "Unknown ability."
                    exit 1
                    ;;
            esac
        done
        ;;
esac

for ability in str dex con int wis cha; do
    case "$ability" in
        "str") str_mod=$(( (str - 10) / 2 )) ;;
        "dex") dex_mod=$(( (dex - 10) / 2 )) ;;
        "con") con_mod=$(( (con - 10) / 2 )) ;;
        "int") int_mod=$(( (int - 10) / 2 )) ;;
        "wis") wis_mod=$(( (wis - 10) / 2 )) ;;
        "cha") cha_mod=$(( (cha - 10) / 2 )) ;;
    esac
done

print_ability "STR" "$str" "$str_mod"
print_ability "DEX" "$dex" "$dex_mod"
print_ability "CON" "$con" "$con_mod"
print_ability "INT" "$int" "$int_mod"
print_ability "WIS" "$wis" "$wis_mod"
print_ability "CHA" "$cha" "$cha_mod"

hp=$(( hit_die + con_mod ))

case "$race" in
    "hill-dwarf") hp=$(( hp + 1 )) ;;
esac

green_message "HP:" "$hp"
