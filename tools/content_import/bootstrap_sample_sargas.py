#!/usr/bin/env python3
import os

SARGAS_CONTENT = {
    "bala_kanda_sarga_001.txt": "Ascetic Valmiki asked Narada, pre-eminent in virtuous learning: Who in the world today is heroic and righteous?",
    "ayodhya_kanda_sarga_001.txt": "King Dasaratha resolved to crown Rama. Kaikeyi demanded his exile to the forest.",
    "aranya_kanda_sarga_001.txt": "Entering the deep forest, Rama, Lakshmana, and Sita encountered demons. Ravana abducted Sita.",
    "kishkindha_kanda_sarga_001.txt": "Rama met Sugriva and Hanuman, forming an alliance to search for Sita.",
    "sundara_kanda_sarga_001.txt": "Hanuman crossed the southern ocean, located Sita in Lanka, and consoled her.",
    "yuddha_kanda_sarga_001.txt": "Rama built the bridge to Lanka, slew Ravana, rescued Sita, and returned to Ayodhya.",
    "uttara_kanda_sarga_001.txt": "Rama reigned righteously over Ayodhya. Lava and Kusha sang the epic before him."
}

def main():
    sargas_dir = os.path.join(os.path.dirname(__file__), "data", "sargas")
    os.makedirs(sargas_dir, exist_ok=True)
    
    for filename, text in SARGAS_CONTENT.items():
        filepath = os.path.join(sargas_dir, filename)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(text)
        print(f"Created sample Sarga text file: {filename}")

if __name__ == "__main__":
    main()
