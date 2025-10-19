# app/seeds/seed_data.py
import asyncio
import random
from typing import Dict, List, Set, Tuple
from uuid import uuid4
from datetime import datetime, timedelta
from sqlalchemy import text


from faker import Faker

# IMPORT YOUR DB + MODELS (adjust if your module paths differ)
from app.core.db import Base, SessionLocal, engine
from app.models import (
    Brand,
    Package,
    Pharmacy,
    PharmacyInventory,
    Product,
    ProductImage,
    Translation,
)

# --- Configuration ---
NUM_PRODUCTS = 20
NUM_PHARMACIES = 100
TARGET_PACKAGES = 400

# If you want the script to create tables (only for dev/test): set True.
CREATE_TABLES = False

# Faker locales
fake_de = Faker("de_DE")
fake_sk = Faker("sk_SK")
fake_en = Faker("en_US")
Faker.seed(42)
random.seed(42)

# Special Paracetamol images for presentation
PARACETAMOL_IMAGES = [
    # Add your 10-20 URLs here for Paracetamol specifically
    "https://www.laboratoriochile.cl/wp-content/uploads/2019/03/Paracetamol_80MG_16CM_HD.jpg",
    "https://images.apopoint.at/dam/product/1181280/800/pimProductBatchZip_82306c806c7d6b8aec4ed6b01d862755.",
    "https://assets.sayacare.in/api/images/product_image/large_image/23/74/Paracetamol-500-mg-Tablet_1.webp",
    "https://www.apotheke.at/images/product_images/info_images/04088380.jpg",
    "https://www.apotheke.at/images/product_images/popup_images/paracetamol-genericon-500-mg-tabletten-10-stk-pzn-08200656.jpg",
    "https://www.apotheke.at/images/product_images/info_images/paracetamol-500-1a-pharma-20-stk-pzn-02481587.jpg",
    "https://www.travelpharm.com/uploads/images/products/large/peakpharmacy-everyday-essentials-paracetamol-500mg-pain-relief-tablets-x-16-1726474344Paracetamol-500mg-Pain-Relief-Tablets-x-16.jpg",
    "https://www.erste-hilfe-welt.de/wp-content/uploads/Paracetamol-1.jpg",
    "https://www.mccabespharmacy.com/cdn/shop/files/PfizerParacetamol500mgFilmCoatedTablets24Pack.jpg?v=1704467734",
    "https://cdn.prod.website-files.com/65706eae2e17af935e56a919/6675f33b753697f2468f96e7_paracetamol_adgc_pzn17502473-01.webp",
    "https://www.pharmacyonline.co.uk/uploads/images/products/large/pharmacy-online-paracetamol-paracetamol-500mg-100-tablets-1602960473paracetamol-1.jpg",
    "https://www.xalmeds.com/cdn/shop/files/IMG_3166.jpg?v=1753020416",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRN96qXKmWpIVhRwgFM1OGGa_uGA-JZ7axMMw&s",
    "https://pharmacysavings.com.au/cdn/shop/files/panamax_50_345x@2x.jpg?v=1743931266",
    "https://m.media-amazon.com/images/I/71UAisL0eaL._UF894,1000_QL80_.jpg",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR7yG1lwrSpM3U467ur9N5X6qWxRUgTzev5NQ&s",
    "https://www.chemistwarehouse.com.au/_next/image?url=https%3A%2F%2Fstatic.chemistwarehouse.com.au%2Fams%2Fmedia%2Fpi%2F110144%2FF2D_800.jpg&w=3840&q=75",
    "https://cdn.shop-apotheke.com/images/D01/126/111/D01126111-p1.jpg",
    "https://assets.sainsburys-groceries.co.uk/gol/1132564/1/640x640.jpg",
    "https://kidsapo.com/wp-content/uploads/2024/07/biofarm-paracetamol-500-mg-20-tabl.jpg",
]

# Generic product images
GENERIC_IMAGES = [
    "https://img.freepik.com/free-vector/fake-drugs-carton-package-box_1441-4154.jpg?semt=ais_hybrid&w=740&q=80",
    "https://img.freepik.com/premium-photo/package-with-two-blisters-with-medicines-pills-mockup-template-3d-rendering_433979-2543.jpg",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTqzcQnp7bkNQCJT1-wDVQwBiJ6ImEqARQCT8-dB7VvrAwMTsg5T4pZvpXoJRrs1fhqrRE&usqp=CAU",
    "https://www.newrulefx.com/cdn/shop/files/f04b0f01-2490-42d6-aa4a-3952f7c2b788.jpg?v=1704721800&width=750",
    "https://img.freepik.com/premium-photo/tablets-pills-drugs-pharmacy-medicine-medical-white-background_1339-53819.jpg?semt=ais_hybrid&w=740&q=80",
    "https://t3.ftcdn.net/jpg/02/16/83/98/360_F_216839888_M1SCoZXUnrs3n9r94iq7ZqesFlU2U8Lh.jpg",
    "https://img.freepik.com/premium-photo/white-box-with-white-box-that-saysxon-it_876146-705.jpg?semt=ais_hybrid&w=740&q=80",
]

# Expanded realistic product list with proper ATC codes
PRODUCTS = [
    ("Paracetamol", "N02BE01", "tablet", ["500 mg", "1000 mg"]),  # Forced to be tablet
    ("Ibuprofen", "M01AE01", "tablet", ["200 mg", "400 mg", "600 mg"]),
    ("Aspirin", "N02BA01", "tablet", ["100 mg", "300 mg", "500 mg"]),
    ("Omeprazole", "A02BC01", "capsule", ["20 mg", "40 mg"]),
    ("Cetirizine", "R06AE07", "tablet", ["10 mg"]),
    ("Metformin", "A10BA02", "tablet", ["500 mg", "850 mg", "1000 mg"]),
    ("Amoxicillin", "J01CA04", "capsule", ["250 mg", "500 mg"]),
    ("Lisinopril", "C09AA03", "tablet", ["5 mg", "10 mg", "20 mg"]),
    ("Atorvastatin", "C10AA05", "tablet", ["10 mg", "20 mg", "40 mg"]),
    ("Diclofenac", "M01AB05", "tablet", ["50 mg", "75 mg"]),
    ("Levothyroxine", "H03AA01", "tablet", ["25 mcg", "50 mcg", "100 mcg"]),
    ("Furosemide", "C03CA01", "tablet", ["20 mg", "40 mg"]),
    ("Losartan", "C09CA01", "tablet", ["25 mg", "50 mg", "100 mg"]),
    ("Hydrochlorothiazide", "C03AA03", "tablet", ["12.5 mg", "25 mg"]),
    ("Pantoprazole", "A02BC02", "tablet", ["20 mg", "40 mg"]),
    ("Salbutamol", "R03AC02", "spray", ["100 mcg/dose"]),
    ("Simvastatin", "C10AA01", "tablet", ["10 mg", "20 mg", "40 mg"]),
    ("Doxycycline", "J01AA02", "capsule", ["100 mg"]),
    ("Loratadine", "R06AX13", "tablet", ["10 mg"]),
    ("Vitamin D3", "A11CC05", "capsule", ["1000 IU", "2000 IU"]),
]

# Realistic manufacturers
MANUFACTURERS = [
    "Bayer", "Pfizer", "Sandoz", "Novartis", "Teva", "Stada", "Roche", "GSK", 
    "Merck", "Sanofi", "Boehringer Ingelheim", "AbbVie", "Takeda", "Mylan",
    "Actavis", "Zentiva", "Hexal", "Ratiopharm", "1A Pharma", "Aliud"
]

# Pack sizes by form
PACK_SIZES = {
    "tablet": ["10 tablets", "20 tablets", "30 tablets", "50 tablets", "100 tablets"],
    "capsule": ["10 capsules", "20 capsules", "30 capsules", "50 capsules", "100 capsules"],
    "spray": ["100 doses", "200 doses"],
    "syrup": ["100 ml", "200 ml", "250 ml"],
    "cream": ["30 g", "50 g", "100 g"],
    "ointment": ["30 g", "50 g", "100 g"]
}

# City coordinates for Germany & Slovakia
CITY_COORDS: Dict[str, tuple] = {
    # Germany
    "Berlin": (52.5200, 13.4050),
    # Slovakia  
    "Bratislava": (48.1486, 17.1077),
}

COUNTRY_BY_CITY = {
    "Berlin": "DE",
    "Bratislava": "SK",
}

# --- helpers ---
def gen_uuid() -> str:
    return str(uuid4())

def generate_unique_gtin() -> str:
    """Generate a unique 13-digit GTIN"""
    return "".join(str(random.randint(0, 9)) for _ in range(13))

def translate_for_lang(inn: str, strength: str, form: str, lang: str) -> str:
    """Translate product info for given language"""
    form_map = {
        "de": {
            "tablet": "Tabletten", "capsule": "Kapseln", "syrup": "Sirup",
            "cream": "Creme", "spray": "Spray", "ointment": "Salbe"
        },
        "sk": {
            "tablet": "tablety", "capsule": "kapsuly", "syrup": "sirup",
            "cream": "krém", "spray": "sprej", "ointment": "masť"
        },
    }
    ftrans = form_map.get(lang, {}).get(form, form)
    return f"{inn} {strength} {ftrans}"

def get_description_for_lang(lang: str) -> str:
    """Get product description in specified language"""
    descriptions = {
        "de": "Hochwertige Arzneimittel mit bewährter Wirksamkeit. Beliebte Wahl bei Kunden für ihr Preis-Leistungs-Verhältnis.",
        "sk": "Vysokokvalitné lieky s osvedčenou účinnosťou. Obľúbená voľba medzi zákazníkmi pre svoj pomer ceny a kvality.",
        "en": "High-quality medication with proven effectiveness. Popular choice among customers for its value."
    }
    return descriptions.get(lang, descriptions["en"])

async def clear_all_tables(session):
    """Clear all data from tables in correct order to respect foreign keys"""
    print("🗑️ Clearing existing data...")
    await session.execute(text("DELETE FROM pharmacy_inventory"))
    await session.execute(text("DELETE FROM product_images"))
    await session.execute(text("DELETE FROM translations"))
    await session.execute(text("DELETE FROM packages"))
    await session.execute(text("DELETE FROM brands"))
    await session.execute(text("DELETE FROM pharmacies"))
    await session.execute(text("DELETE FROM products"))
    await session.commit()
    print("✅ All tables cleared")

async def main():
    if CREATE_TABLES:
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)

    async with SessionLocal() as session:
        # Clear existing data
        await clear_all_tables(session)
        
        # Track created objects
        used_gtins: Set[str] = set()
        package_combinations: Set[Tuple] = set()  # (product_id, brand_id, pack_size, country)
        
        # -------------------------
        # PRODUCTS
        # -------------------------
        print("Creating products...")
        product_objs = []
        for inn_name, atc_code, form, strengths in PRODUCTS:
            for strength in strengths:
                p = Product(
                    id=gen_uuid(),
                    inn_name=inn_name,
                    atc_code=atc_code,
                    form=form,
                    strength=strength,
                )
                session.add(p)
                product_objs.append(p)
        
        await session.commit()
        print(f"✅ Created {len(product_objs)} products")

        # -------------------------
        # BRANDS (2-4 per product)
        # -------------------------
        print("Creating brands...")
        brand_objs = []
        for product in product_objs:
            num_brands = random.randint(2, 4)
            used_brand_names = set()
            
            for _ in range(num_brands):
                # Generate unique brand name for this product
                attempts = 0
                while attempts < 10:
                    suffix = random.choice(['', 'Fast', 'Extra', 'Plus', 'Classic', 'Forte', 'Recharge'])
                    brand_name = f"{product.inn_name} {suffix}".strip()
                    if brand_name not in used_brand_names:
                        used_brand_names.add(brand_name)
                        break
                    attempts += 1
                
                b = Brand(
                    id=gen_uuid(),
                    product_id=product.id,
                    brand_name=brand_name,
                    manufacturer=random.choice(MANUFACTURERS),
                )
                session.add(b)
                brand_objs.append(b)
        
        await session.commit()
        print(f"✅ Created {len(brand_objs)} brands")

        # -------------------------
        # PACKAGES (targeting ~400 unique packages)
        # -------------------------
        print("Creating packages...")
        package_objs = []
        countries = ["DE", "SK"]
        
        while len(package_objs) < TARGET_PACKAGES:
            product = random.choice(product_objs)
            product_brands = [b for b in brand_objs if b.product_id == product.id]
            brand = random.choice(product_brands)
            
            # Get appropriate pack sizes for this form
            available_pack_sizes = PACK_SIZES.get(product.form, ["30 pcs"])
            pack_size = random.choice(available_pack_sizes)
            country = random.choice(countries)
            
            # Create unique combination key
            combination_key = (product.id, brand.id, pack_size, country)
            
            # Skip if this combination already exists
            if combination_key in package_combinations:
                continue
                
            # Generate unique GTIN
            gtin = generate_unique_gtin()
            while gtin in used_gtins:
                gtin = generate_unique_gtin()
            used_gtins.add(gtin)
            package_combinations.add(combination_key)
            
            pkg = Package(
                id=gen_uuid(),
                product_id=product.id,
                brand_id=brand.id,
                gtin=gtin,
                pack_size=pack_size,
                country_code=country,
            )
            session.add(pkg)
            package_objs.append(pkg)
        
        await session.commit()
        print(f"✅ Created {len(package_objs)} unique packages")

        # -------------------------
        # PRODUCT IMAGES (1-3 per package)
        # -------------------------
        print("Creating product images...")
        image_objs = []
        
        for pkg in package_objs:
            # Find product for this package
            product = next(p for p in product_objs if p.id == pkg.product_id)
            
            # Determine images to use
            if product.inn_name.lower() == "paracetamol":
                available_images = PARACETAMOL_IMAGES.copy()
            else:
                available_images = GENERIC_IMAGES.copy()
            
            # Create 1-3 images per package
            num_images = random.randint(1, min(3, len(available_images)))
            selected_images = random.sample(available_images, num_images)
            
            for i, image_url in enumerate(selected_images):
                img = ProductImage(
                    id=gen_uuid(),
                    package_id=pkg.id,
                    image_url=image_url,
                    is_primary=(i == 0),  # First image is primary
                )
                session.add(img)
                image_objs.append(img)
        
        await session.commit()
        print(f"✅ Created {len(image_objs)} product images")

        # -------------------------
        # TRANSLATIONS (de, sk, en for each product)
        # -------------------------
        print("Creating translations...")
        translation_objs = []
        
        for product in product_objs:
            for lang in ["de", "sk", "en"]:
                tr = Translation(
                    id=gen_uuid(),
                    product_id=product.id,
                    language_code=lang,
                    translated_name=translate_for_lang(
                        product.inn_name, product.strength, product.form, lang
                    ),
                    translated_description=get_description_for_lang(lang),
                )
                session.add(tr)
                translation_objs.append(tr)
        
        await session.commit()
        print(f"✅ Created {len(translation_objs)} translations")

        # -------------------------
        # PHARMACIES (~100 across multiple cities)
        # -------------------------
        print("Creating pharmacies...")
        pharmacy_objs = []
        
        cities = list(CITY_COORDS.keys())
        for _ in range(NUM_PHARMACIES):
            city = random.choice(cities)
            country_code = COUNTRY_BY_CITY[city]
            fake = fake_de if country_code == "DE" else fake_sk
            
            # Add realistic jitter to coordinates
            lat0, lng0 = CITY_COORDS[city]
            lat = lat0 + random.uniform(-0.05, 0.05)
            lng = lng0 + random.uniform(-0.05, 0.05)
            
            # Generate realistic opening hours
            opening_hours = {
                "monday": "08:00-18:00",
                "tuesday": "08:00-18:00", 
                "wednesday": "08:00-18:00",
                "thursday": "08:00-18:00",
                "friday": "08:00-18:00",
                "saturday": "09:00-14:00" if random.random() > 0.3 else "closed",
                "sunday": "closed" if random.random() > 0.1 else "10:00-16:00",
            }
            
            ph = Pharmacy(
                id=gen_uuid(),
                name=f"{fake.company()} {'Apotheke' if country_code == 'DE' else 'Lekáreň'}",
                country=country_code,
                city=city,
                address=fake.street_address(),
                lat=str(round(lat, 6)),
                lng=str(round(lng, 6)),
                phone=fake.phone_number(),
                opening_hours=opening_hours,
            )
            session.add(ph)
            pharmacy_objs.append(ph)
        
        await session.commit()
        print(f"✅ Created {len(pharmacy_objs)} pharmacies")

        # -------------------------
        # PHARMACY INVENTORY (realistic stock distribution)
        # -------------------------
        print("Creating pharmacy inventory...")
        inventory_objs = []
        
        for pharmacy in pharmacy_objs:
            # Each pharmacy stocks 20-60 different packages
            num_packages = random.randint(20, 60)
            selected_packages = random.sample(package_objs, min(num_packages, len(package_objs)))
            
            for pkg in selected_packages:
                # Price varies by region and pharmacy
                base_price = random.randint(299, 4999)  # 2.99 to 49.99 EUR
                price_cents = base_price + random.randint(-50, 150)  # Add some variation
                
                # Stock quantity realistic distribution
                stock_quantity = random.choices(
                    [0, 1, 2, 3, 5, 10, 15, 20, 25, 50],
                    weights=[5, 10, 15, 20, 25, 15, 5, 3, 1, 1]
                )[0]
                
                # Some items were updated recently, others not
                days_ago = random.randint(0, 30)
                last_updated = datetime.now() - timedelta(days=days_ago)
                
                inv = PharmacyInventory(
                    id=gen_uuid(),
                    pharmacy_id=pharmacy.id,
                    package_id=pkg.id,
                    price_cents=max(price_cents, 99),  # Minimum 0.99 EUR
                    currency="EUR",
                    stock_quantity=stock_quantity,
                    last_updated=last_updated,
                )
                session.add(inv)
                inventory_objs.append(inv)
        
        await session.commit()
        print(f"✅ Created {len(inventory_objs)} pharmacy inventory entries")

    # Final summary
    print("\n🎉 Seeding complete!")
    print("=" * 50)
    print(f"📦 Products: {len(product_objs)}")
    print(f"🏷️  Brands: {len(brand_objs)}")
    print(f"📋 Packages: {len(package_objs)} (all unique combinations)")
    print(f"🖼️  Images: {len(image_objs)}")
    print(f"🌐 Translations: {len(translation_objs)}")
    print(f"🏥 Pharmacies: {len(pharmacy_objs)}")
    print(f"📊 Inventory entries: {len(inventory_objs)}")
    print("=" * 50)

if __name__ == "__main__":
    asyncio.run(main())