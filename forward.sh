#!/bin/bash

# File to store port forwarding rules history
HISTORY_FILE="/etc/port_forwarding_rules.txt"
# File to save iptables rules for persistence
IPTABLES_RULES_FILE="/etc/iptables/rules.v4"

# Function to list current port forwarding rules
list_rules() {
    echo "Current port forwarding rules:"
    sudo iptables -t nat -L -n -v
}

# Function to add a new port forwarding rule
add_rule() {
    local src_port
    local dest_ip
    local dest_port

    # Prompt user for inputs if not provided as arguments
    if [[ -z "$1" ]]; then
        read -p "Enter source port: " src_port
    else
        src_port="$1"
    fi
    
    if [[ -z "$2" ]]; then
        read -p "Enter destination IP: " dest_ip
    else
        dest_ip="$2"
    fi
    
    if [[ -z "$3" ]]; then
        read -p "Enter destination port: " dest_port
    else
        dest_port="$3"
    fi

    # Validate inputs
    if [[ -z "$src_port" || -z "$dest_ip" || -z "$dest_port" ]]; then
        echo "Error: Missing arguments. Please provide source port, destination IP, and destination port."
        return 1
    fi
    
    # Add iptables rule
    sudo iptables -t nat -A PREROUTING -p tcp --dport "$src_port" -j DNAT --to-destination "$dest_ip:$dest_port"
    sudo iptables -t nat -A POSTROUTING -p tcp -d "$dest_ip" --dport "$dest_port" -j MASQUERADE
    
    # Save rule to history
    echo "Forward $src_port to $dest_ip:$dest_port" >> "$HISTORY_FILE"
    
    echo "Rule added: Forward $src_port to $dest_ip:$dest_port"
}

# Function to delete an existing port forwarding rule
delete_rule() {
    local src_port
    local dest_ip
    local dest_port

    # Prompt user for inputs if not provided as arguments
    if [[ -z "$1" ]]; then
        read -p "Enter source port: " src_port
    else
        src_port="$1"
    fi
    
    if [[ -z "$2" ]]; then
        read -p "Enter destination IP: " dest_ip
    else
        dest_ip="$2"
    fi
    
    if [[ -z "$3" ]]; then
        read -p "Enter destination port: " dest_port
    else
        dest_port="$3"
    fi

    # Validate inputs
    if [[ -z "$src_port" || -z "$dest_ip" || -z "$dest_port" ]]; then
        echo "Error: Missing arguments. Please provide source port, destination IP, and destination port."
        return 1
    fi
    
    # Delete iptables rule
    sudo iptables -t nat -D PREROUTING -p tcp --dport "$src_port" -j DNAT --to-destination "$dest_ip:$dest_port"
    sudo iptables -t nat -D POSTROUTING -p tcp -d "$dest_ip" --dport "$dest_port" -j MASQUERADE
    
    # Remove rule from history
    sed -i "/Forward $src_port to $dest_ip:$dest_port/d" "$HISTORY_FILE"
    
    echo "Rule deleted: Forward $src_port to $dest_ip:$dest_port"
}

# Function to show the history of port forwarding rules
show_history() {
    if [[ -f "$HISTORY_FILE" ]]; then
        echo "Port forwarding rules history:"
        cat "$HISTORY_FILE"
    else
        echo "No history found."
    fi
}

# Function to save iptables rules
save_rules() {
    sudo iptables-save | sudo tee "$IPTABLES_RULES_FILE"
    echo "Iptables rules saved to $IPTABLES_RULES_FILE"
}

# Function to display help message
show_help() {
    echo "Usage: $0 {list|add|delete|history|save|help}"
    echo
    echo "list      - List current port forwarding rules"
    echo "add       - Add a new port forwarding rule"
    echo "delete    - Delete an existing port forwarding rule"
    echo "history   - Show the history of port forwarding rules"
    echo "save      - Save current iptables rules"
    echo "help      - Show this help message"
}

# Main script logic
case "$1" in
    list)
        list_rules
        ;;
    add)
        add_rule "$2" "$3" "$4"
        ;;
    delete)
        delete_rule "$2" "$3" "$4"
        ;;
    history)
        show_history
        ;;
    save)
        save_rules
        ;;
    help)
        show_help
        ;;
    *)
        echo "Error: Invalid option."
        show_help
        exit 1
        ;;
esac
