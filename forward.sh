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
    local src_port="$1"
    local dest_ip="$2"
    local dest_port="$3"
    
    if [[ -z "$src_port" || -z "$dest_ip" || -z "$dest_port" ]]; then
        echo "Usage: add_rule <src_port> <dest_ip> <dest_port>"
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
    local src_port="$1"
    local dest_ip="$2"
    local dest_port="$3"
    
    if [[ -z "$src_port" || -z "$dest_ip" || -z "$dest_port" ]]; then
        echo "Usage: delete_rule <src_port> <dest_ip> <dest_port>"
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
    *)
        echo "Usage: $0 {list|add|delete|history|save}"
        exit 1
        ;;
esac
