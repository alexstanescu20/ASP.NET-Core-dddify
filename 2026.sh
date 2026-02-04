#!/bin/bash

# Ensure the repository is up-to-date
git pull origin main

input_year=2026

# Set variables
start_date="$input_year-01-20"
end_date="$input_year-4-20"
total_commits=30        # Total commits to generate (multiple per day allowed)

# Generate Philippines public holidays
generate_holidays() {
    local year=$1
    holidays=(
       "$year-01-01"
        "$year-01-02"
        "$year-01-03"
        "$year-01-04"   # New Year's Day
        "$year-01-05"
        "$year-01-06"
        "$year-01-07" 
        "$year-01-24"
        "$year-01-25"
        "$year-01-26"  # EDSA People Power Revolution
        "$year-04-10"   # Araw ng Kagitingan
        "$year-04-11"   # Labor Day
        "$year-04-12"   # Labor Day
        "$year-04-13"   # Labor Day   # Labor Day
        "$year-05-01"   # Independence Day
        "$year-05-03"   # Ninoy Aquino Day
        "$year-05-31"   # All Saints' Day
        "$year-06-01"   # Bonifacio Day
        "$year-08-15"   # Bonifacio Day
        "$year-08-16"   # Bonifacio Day
        "$year-11-01"   # Bonifacio Day
        "$year-11-02"   # Bonifacio Day
        "$year-12-20"   # Christmas Day
        "$year-12-21"   # Christmas Day
        "$year-12-22"   # Christmas Day
        "$year-12-23"   # Christmas Day
        "$year-12-24"   # Christmas Day
        "$year-12-25"   # Christmas Day
        "$year-12-26"   # Christmas Day
        "$year-12-27"   # Rizal Day
        "$year-12-28"   # Rizal Day
        "$year-12-29"   # Rizal Day
        "$year-12-30"
        "$year-12-31"   # Rizal Day
    )

    # Movable holidays (approximations)
    # Maundy Thursday & Good Friday (Easter-based)
    easter_sunday=$(date -d "$year-03-21 + $(expr $(date -d "$year-03-21" +%j) % 7) days + 50 days" +%Y-%m-%d 2>/dev/null || echo "$year-04-04")  # Approx
    good_friday=$(date -d "$easter_sunday - 2 days" +%Y-%m-%d 2>/dev/null || echo "$year-04-02")
    maundy_thursday=$(date -d "$easter_sunday - 3 days" +%Y-%m-%d 2>/dev/null || echo "$year-04-01")

    holidays+=("$maundy_thursday" "$good_friday")
}

generate_holidays "$input_year"

# Generate weekdays (Monday - Friday) within date range excluding holidays
dates_weekdays=()
current_date="$start_date"

while [[ "$current_date" < "$end_date" ]] || [[ "$current_date" == "$end_date" ]]; do
    day_of_week=$(date -d "$current_date" +%u 2>/dev/null || echo $(date -j -f "%Y-%m-%d" "$current_date" +%u))

    # Skip weekends and holidays
    if [[ "$day_of_week" -lt 6 ]] && [[ ! " ${holidays[@]} " =~ " $current_date " ]]; then
        dates_weekdays+=("$current_date")
    fi

    current_date=$(date -I -d "$current_date + 1 day" 2>/dev/null || echo $(date -j -v+1d -f "%Y-%m-%d" "$current_date" "+%Y-%m-%d"))
done

total_days=${#dates_weekdays[@]}
echo "Number of valid weekdays: $total_days"

if [[ "$total_days" -eq 0 ]]; then
    echo "No valid weekdays available."
    exit 1
fi

# Make commits
for ((i=1; i<=total_commits; i++)); do
    # Pick a random day from valid weekdays
    day=${dates_weekdays[$RANDOM % total_days]}

    # Pick a random hour and minute (so multiple commits appear separately)
    hour=$(printf "%02d" $((RANDOM % 9 + 9)))   # 09:00 - 17:59
    minute=$(printf "%02d" $((RANDOM % 60)))
    second=$(printf "%02d" $((RANDOM % 60)))

    commit_date="$day $hour:$minute:$second"
    export GIT_COMMITTER_DATE="$commit_date"
    export GIT_AUTHOR_DATE="$commit_date"

    git commit --allow-empty -m "Modify files" --date "$commit_date"
done

git push origin main
echo "Multiple commits per day generated successfully (Poland holidays)."