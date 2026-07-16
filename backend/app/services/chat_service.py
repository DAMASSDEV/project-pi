class ChatService:
    @staticmethod
    def get_bot_response(message: str) -> str:
        msg = message.lower()
        if "asinan" in msg:
            return "Asinan Bogor memiliki estimasi sekitar 150 kkal per porsi. Hidangan segar ini kaya akan serat, Vitamin C, dan antioksidan karena terdiri dari buah-buahan dan sayuran segar dengan kuah asam pedas."
        elif "cungkring" in msg:
            return "Cungkring memiliki estimasi sekitar 255 kkal per porsi (100g). Kandungan utamanya adalah protein hewani dari kikil dan paru sapi, namun cukup tinggi lemak jenuh, jadi konsumsilah dalam porsi wajar."
        elif "telur" in msg:
            return "Satu butir telur rebus mengandung sekitar 78 kkal, 6 gram protein berkualitas tinggi, serta vitamin D dan B12. Sangat baik untuk pemulihan otot."
        elif "makan" in msg or "ide" in msg or "saran" in msg:
            return "Ide makan sehat tinggi protein: Dada ayam panggang dengan tumis brokoli dan nasi merah. Total kalori sekitar 450 kkal dengan kandungan protein sekitar 40g."
        else:
            return "Halo! Saya adalah asisten gizi pintar Anda. Tanyakan kepada saya tentang estimasi kalori makanan khas Bogor (seperti Asinan atau Cungkring), rekomendasi gizi, atau tips diet Anda."
