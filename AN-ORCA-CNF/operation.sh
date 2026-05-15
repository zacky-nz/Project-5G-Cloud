#!/bin/bash

CORE_NS="${CORE_NS:-core-network}"
RAN_NS="${RAN_NS:-ran-network}"

while true; do
    echo "Select an operation to perform:"
    echo "1. Install Core Network"
    echo "2. Install gNB to UE (Single)"
    echo "3. Install gNB to UE (MDU)"
    echo "4. Install gNB to UE (MUE)"
    echo "5. Upgrade Core Network"
    echo "6. Upgrade gNB to UE (Single)"
    echo "7. Upgrade gNB to UE (MDU)"
    echo "8. Upgrade gNB to UE (MUE)"
    echo "9. Uninstall Core Network"
    echo "10. Uninstall gNB to UE (Single)"
    echo "11. Uninstall gNB to UE (MDU)"
    echo "12. Uninstall gNB to UE (MUE)"
    echo "13. Exit"
    read -p "Enter your choice (1-13): " choice

    case $choice in
        1)
            kubectl create namespace "$CORE_NS" --dry-run=client -o yaml | kubectl apply -f -
            helm install basic ./oai-5g-core/oai-5g-basic/ -n "$CORE_NS"
            echo "Core network installed."
            echo
            ;;
        2)
            # Install gNB to UE (Single)
            kubectl create namespace "$RAN_NS" --dry-run=client -o yaml | kubectl apply -f -
            helm install oai-cu-level1 ./user_n/oai-e2e/oai-cu/ -n "$RAN_NS"
            helm install oai-du-level1 ./user_n/oai-e2e/oai-du/ -n "$RAN_NS"
            helm install oai-nr-ue-level1 ./user_n/oai-e2e/oai-nr-ue/ -n "$RAN_NS"
            echo "gNB to UE (Single) installed."
            echo
            ;;
        3)
            # Install gNB to UE (MDU)
            kubectl create namespace "$RAN_NS" --dry-run=client -o yaml | kubectl apply -f -
            helm install oai-cu-level2 ./user_n/oai-multi-gnb/oai-cu/ -n "$RAN_NS"
            helm install oai-du1-level2 ./user_n/oai-multi-gnb/oai-du-1/ -n "$RAN_NS"
            helm install oai-du2-level2 ./user_n/oai-multi-gnb/oai-du-2/ -n "$RAN_NS"
            helm install oai-nr-ue1-level2 ./user_n/oai-multi-gnb/oai-nr-ue-1/ -n "$RAN_NS"
            helm install oai-nr-ue2-level2 ./user_n/oai-multi-gnb/oai-nr-ue-2/ -n "$RAN_NS"
            echo "gNB to UE (MDU) installed."
            echo
            ;;
        4)
            # Install gNB to UE (MUE)
            kubectl create namespace "$RAN_NS" --dry-run=client -o yaml | kubectl apply -f -
            helm install oai-cu-level3 ./user_n/oai-multi-ue/oai-cu/ -n "$RAN_NS"
            helm install oai-du-level3 ./user_n/oai-multi-ue/oai-du/ -n "$RAN_NS"
            helm install oai-nr-ue1-level3 ./user_n/oai-multi-ue/oai-nr-ue-1/ -n "$RAN_NS"
            # helm install oai-nr-ue2-level3 ./user_n/oai-multi-ue/oai-nr-ue-2/ -n "$RAN_NS"
            echo "gNB to UE (MUE) installed."
            echo
            ;;
        5)
            # Upgrade Core Network
            helm upgrade basic ./oai-5g-core/oai-5g-basic/ -n "$CORE_NS"
            echo "Core network upgraded."
            echo
            ;;
        6)
            # Upgrade gNB to UE (Single)
            helm upgrade oai-cu-level1 ./user_n/oai-e2e/oai-cu/ -n "$RAN_NS"
            helm upgrade oai-du-level1 ./user_n/oai-e2e/oai-du/ -n "$RAN_NS"
            helm upgrade oai-nr-ue-level1 ./user_n/oai-e2e/oai-nr-ue/ -n "$RAN_NS"
            echo "gNB to UE (Single) upgraded."
            echo
            ;;
        7)
            # Upgrade gNB to UE (MDU)
            helm upgrade oai-cu-level2 ./user_n/oai-multi-gnb/oai-cu/ -n "$RAN_NS"
            helm upgrade oai-du1-level2 ./user_n/oai-multi-gnb/oai-du-1/ -n "$RAN_NS"
            helm upgrade oai-du2-level2 ./user_n/oai-multi-gnb/oai-du-2/ -n "$RAN_NS"
            helm upgrade oai-nr-ue1-level2 ./user_n/oai-multi-gnb/oai-nr-ue-1/ -n "$RAN_NS"
            helm upgrade oai-nr-ue2-level2 ./user_n/oai-multi-gnb/oai-nr-ue-2/ -n "$RAN_NS"
            echo "gNB to UE (MDU) upgraded."
            echo
            ;;
        8)
            # Upgrade gNB to UE (MUE)
            helm upgrade oai-cu-level3 ./user_n/oai-multi-ue/oai-cu/ -n "$RAN_NS"
            helm upgrade oai-du-level3 ./user_n/oai-multi-ue/oai-du/ -n "$RAN_NS"
            helm upgrade oai-nr-ue1-level3 ./user_n/oai-multi-ue/oai-nr-ue-1/ -n "$RAN_NS"
            # helm upgrade oai-nr-ue2-level3 ./user_n/oai-multi-ue/oai-nr-ue-2/ -n "$RAN_NS"
            echo "gNB to UE (MUE) upgraded."
            echo
            ;;
        9)
            # Uninstall Core Network
            helm uninstall basic -n "$CORE_NS"
            echo "Core network uninstalled."
            echo
            ;;
        10)
            # Uninstall gNB to UE (Single)
            helm uninstall oai-cu-level1 -n "$RAN_NS"
            helm uninstall oai-du-level1 -n "$RAN_NS"
            helm uninstall oai-nr-ue-level1 -n "$RAN_NS"
            echo "gNB to UE (Single) uninstalled."
            echo
            ;;
        11)
            # Uninstall gNB to UE (MDU)
            helm uninstall oai-cu-level2 -n "$RAN_NS"
            helm uninstall oai-du1-level2 -n "$RAN_NS"
            helm uninstall oai-du2-level2 -n "$RAN_NS"
            helm uninstall oai-nr-ue1-level2 -n "$RAN_NS"
            helm uninstall oai-nr-ue2-level2 -n "$RAN_NS"
            echo "gNB to UE (MDU) uninstalled."
            echo
            ;;
        12)
            # Uninstall gNB to UE (MUE)
            helm uninstall oai-cu-level3 -n "$RAN_NS"
            helm uninstall oai-du-level3 -n "$RAN_NS"
            helm uninstall oai-nr-ue1-level3 -n "$RAN_NS"
            # helm uninstall oai-nr-ue2-level3 -n "$RAN_NS"
            echo "gNB to UE (MUE) uninstalled."
            echo
            ;;
        13)
            echo "Exiting..."
            echo
            break
            ;;
        *)
            echo "Invalid option, please try again."
            echo
            ;;
    esac
done
