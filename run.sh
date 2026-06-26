#!/bin/bash

run_backend() {
  cd backend && python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
}

run_frontend() {
  cd frontend && flutter run
}

run_mobile() {
  flutter emulators --launch Medium_Phone_API_36.0
  cd frontend && flutter run -d Medium_Phone_API_36.0
}

run_all() {
  cd backend && python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload &
  BACKEND_PID=$!
  trap 'kill $BACKEND_PID; exit' INT TERM EXIT
  cd ../frontend && flutter run
}

if [ "$1" = "backend" ]; then
  run_backend
elif [ "$1" = "frontend" ]; then
  run_frontend
elif [ "$1" = "mobile" ]; then
  run_mobile
else
  run_all
fi
