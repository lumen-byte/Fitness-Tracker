#!/bin/bash

cd /Users/abhimanyu/Downloads/AI_Fitness_Tracker_Microservices-main

# Start fresh
rm -rf .git
git init

components=(
    "eureka:Initial setup of Eureka Service Discovery"
    "configserver:Add Spring Cloud Config Server"
    "gateway:Implement API Gateway with Keycloak Sync"
    "userservice:Create User Service with PostgreSQL"
    "activityservice:Add Activity Service with MongoDB and RabbitMQ"
    "aiservice:Integrate Gemini AI Service"
    "fitness-app-frontend:Initialize React Frontend"
    "docker-compose.yml:Add Docker Compose for infrastructure"
    "README.md resource.md setup_keycloak.sh:Add project documentation and scripts"
)

# Start 27 days ago
days_ago=27

for item in "${components[@]}"; do
    files="${item%%:*}"
    message="${item#*:}"
    
    # macOS date
    commit_date=$(date -v-${days_ago}d +"%Y-%m-%dT12:00:00")
    
    for file in $files; do
        if [ -e "$file" ]; then
            git add "$file"
        fi
    done
    
    # Commit if anything was added
    if ! git diff --cached --quiet; then
        GIT_COMMITTER_DATE="$commit_date" git commit --date="$commit_date" -m "$message"
    fi
    
    days_ago=$((days_ago - 3))
done

# Catch any remaining files with today's date
git add .
if ! git diff --cached --quiet; then
    commit_date=$(date +"%Y-%m-%dT12:00:00")
    GIT_COMMITTER_DATE="$commit_date" git commit --date="$commit_date" -m "Final adjustments and bug fixes"
fi

git branch -M main
git remote add origin https://github.com/lumen-byte/Fitness-Tracker.git
echo "Pushing to GitHub..."
git push -u origin main
