#!/bin/bash

USER_NAME="auto_fix_tool"

# Read multiple image names (one per line) from images.cfg
while IFS= read -r IMAGE_NAME || [ -n "$IMAGE_NAME" ]; do
  [ -z "$IMAGE_NAME" ] && continue  # skip empty lines

  docker image pull "$IMAGE_NAME"
  ENTRYPOINT_STR=$(docker inspect -f '{{json .Config.Entrypoint}}' "$IMAGE_NAME")
  CMD_STR=$(docker inspect -f '{{json .Config.Cmd}}' "$IMAGE_NAME")
  docker=$(docker ps -aq)

  echo "=============================="
  echo "Start to process $IMAGE_NAME"
  echo "=============================="

  docker run --entrypoint="" "$IMAGE_NAME" bash -c "apt-get update && apt-get upgrade -y"<<EOF
EOF

  echo "finish. Run again;"
  echo "apt-get update && apt-get upgrade -y;"
  echo "finish and start to run EBI_CL-1.07"

  for i in $(find / -perm -6000 2>/dev/null); do chmod a-s "$i"; done
  for i in $(find / -perm -6000 2>/dev/null); do chmod a-s "$i"; done
  exit;

  CONTAINER_ID=$(docker ps -a | grep "$IMAGE_NAME" | awk '{print $1}')
  echo "IMAGE_NAME: $IMAGE_NAME"
  echo "CONTAINER_ID: $CONTAINER_ID"
  echo "ENTRYPOINT_STR: $ENTRYPOINT_STR"
  echo "CMD_STR: $CMD_STR"

  if [[ "$ENTRYPOINT_STR" == "[]" || "$ENTRYPOINT_STR" == "null" || "$ENTRYPOINT_STR" == "" ]]; then
    if [[ "$CMD_STR" == "[]" || "$CMD_STR" == "null" || "$CMD_STR" == "" ]]; then
      echo "process with ENTRYPOINT_STR and CMD_STR empty"
      docker commit -m "update os packages" "$CONTAINER_ID" "$IMAGE_NAME"
    else
      echo "process with ENTRYPOINT_STR empty"
      docker commit --change="CMD $CMD_STR" -m "update os packages" "$CONTAINER_ID" "$IMAGE_NAME"
    fi
  else
    if [[ "$CMD_STR" == "[]" || "$CMD_STR" == "null" || "$CMD_STR" == "" ]]; then
      echo "process with CMD_STR empty"
      docker commit --change="ENTRYPOINT $ENTRYPOINT_STR" -m "update os packages" "$CONTAINER_ID" "$IMAGE_NAME"
    else
      echo "process with ENTRYPOINT_STR and CMD_STR not empty"
      docker commit --change="ENTRYPOINT $ENTRYPOINT_STR" --change="CMD $CMD_STR" -m "update os packages" "$CONTAINER_ID" "$IMAGE_NAME"
    fi
  fi

  docker push "$IMAGE_NAME"
  echo "=============================="
  echo "Completed processing $IMAGE_NAME"
  echo "=============================="

done < images.cfg