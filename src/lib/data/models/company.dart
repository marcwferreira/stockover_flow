class Company {
    final int id;
    final String symbol;
    final String name;
    final String type;
    final double value;
    bool isFollowing;

    Company({
        required this.id,
        required this.symbol,
        required this.name,
        required this.type,
        required this.value,
        this.isFollowing = false,
    });

    Company copyWith({
        int? id,
        String? symbol,
        String? name,
        String? type,
        double? value,
        bool? isFollowing,
    }) {
        return Company(
            id: id ?? this.id,
            symbol: symbol ?? this.symbol,
            name: name ?? this.name,
            type: type ?? this.type,
            value: value ?? this.value,
            isFollowing: isFollowing ?? this.isFollowing,
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'symbol': symbol,
            'name': name,
            'value': value,
            'type': type,
            'isFollowing': isFollowing,
        };
    }

    factory Company.fromJson(Map<String, dynamic> json) {
        return Company(
            id: json['id'],
            symbol: json['symbol'] ?? '',  // Ensure symbol is not null
            name: json['name'] ?? '',  // Ensure name is not null
            value: (json['value'] ?? 0).toDouble(),  // Ensure value is not null and convert to double
            type: json['type'] ?? '',  // Ensure type is not null
            isFollowing: json['isFollowing'] ?? false,  // Ensure isFollowing is not null
        );
    }
}
