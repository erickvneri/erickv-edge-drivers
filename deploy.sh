DRIVERS_PATH="$1"
TARGET_CHANNEL="$2"
TOKEN="$3"

deploy() {
    DRIVER_FOLDER="$1"

    pushd "$DRIVERS_PATH/$DRIVER_FOLDER";
    DRIVER_UUID=$(
        smartthings edge:drivers:package --json --token $TOKEN | \
        jq .driverId | \
        tr -d '"'
    );
    echo "driver $DRIVER_FOLDER$DRIVER_UUID packaged correctly"

    smartthings edge:channels:assign "$DRIVER_UUID" \
        --channel $TARGET_CHANNEL \
        --token $TOKEN && \
        echo "driver $DRIVER_FOLDER$DRIVER_UUID released correctly";

    popd;
}

main () {
    cd $DRIVERS_PATH;
    for DRIVER_DIR in $(ls -d */); do
        deploy $DRIVER_DIR;
    done;
}

