# app/seeds/seed_data.py
import asyncio
import random
from typing import Dict
from uuid import uuid4

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
NUM_PHARMACIES = 10
MIN_PACKAGES = 40
MAX_PACKAGES = 60

# If you want the script to create tables (only for dev/test): set True.
# In production you normally run alembic migrations and keep this False.
CREATE_TABLES = False

# Faker locales
fake_de = Faker("de_DE")
fake_sk = Faker("sk_SK")
fake_en = Faker("en_US")
Faker.seed(42)
random.seed(42)

# Some realistic product names + a few known ATC codes (others left None)
PRODUCTS = [
    ("Paracetamol", "N02BE01"),
    ("Ibuprofen", "M01AE01"),
    ("Aspirin", "N01M456"),
    ("Vitamin C", "A128G6A"),
    ("Omeprazole", "F156B67"),
    ("Cetirizine", "S186J45"),
    ("Metformin", "V756J06"),
    ("Amoxicillin", "K560N65"),
    ("Lisinopril", "I615H45"),
    ("Atorvastatin", "O658Y65"),
    ("Diclofenac", "W156F56"),
    ("Levothyroxine", "R756M32"),
    ("Furosemide", "RQW652J"),
    ("Losartan", "HU26I75"),
    ("Hydrochlorothiazide", "ASD786J"),
    ("Pantoprazole", "JKL756H"),
    ("Salbutamol", "UIO927J"),
    ("Simvastatin", "QJL716J"),
    ("Doxycycline", "JIQ752D"),
    ("Ranitidine", "DA567WA"),
]

FORMS = ["tablet", "capsule", "syrup", "cream", "spray", "ointment"]
STRENGTHS = [
    "100 mg",
    "200 mg",
    "250 mg",
    "300 mg",
    "400 mg",
    "500 mg",
    "5 mg/ml",
    "10 mg/ml",
]

# City coordinates for Germany & Slovakia (center) — will jitter a bit for realism
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


def slugify(s: str) -> str:
    s = s.lower().strip()
    return "".join(ch if ch.isalnum() else "_" for ch in s)


def make_image_url(product_name: str, pack_size: str) -> str:
    slug = slugify(f"{product_name}_{pack_size}")
    return f"https://images.example.com/{slug}.jpg"


def translate_for_lang(inn: str, strength: str, form: str, lang: str) -> str:
    # small deterministic translation approach using term maps
    form_map = {
        "de": {
            "tablet": "Tabletten",
            "capsule": "Kapseln",
            "syrup": "Sirup",
            "cream": "Creme",
            "spray": "Spray",
            "ointment": "Salbe",
        },
        "sk": {
            "tablet": "tablety",
            "capsule": "kapsuly",
            "syrup": "sirup",
            "cream": "krém",
            "spray": "sprej",
            "ointment": "masť",
        },
    }
    ftrans = form_map.get(lang, {}).get(form, form)
    # e.g., "Ibuprofen 400 mg Tabletten"
    return f"{inn} {strength} {ftrans}"


# --- main seeding routine ---
async def main():
    if CREATE_TABLES:
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)

    async with SessionLocal() as session:
        # -------------------------
        # PRODUCTS
        # -------------------------
        product_objs = []
        for i in range(min(NUM_PRODUCTS, len(PRODUCTS))):
            inn_name, atc = PRODUCTS[i]
            p = Product(
                id=gen_uuid(),
                inn_name=inn_name,
                atc_code=atc,
                form=random.choice(FORMS),
                strength=random.choice(STRENGTHS),
            )
            session.add(p)
            product_objs.append(p)
        await session.commit()
        print(f"Created {len(product_objs)} products")

        # -------------------------
        # BRANDS (1-2 per product)
        # -------------------------
        manufacturers = [
            "Bayer",
            "Pfizer",
            "Sandoz",
            "Novartis",
            "Teva",
            "Stada",
            "Roche",
            "GSK",
        ]
        brand_objs = []
        for product in product_objs:
            for _ in range(random.randint(1, 2)):
                b = Brand(
                    id=gen_uuid(),
                    product_id=product.id,
                    brand_name=f"{product.inn_name} {random.choice(['Fast', 'Extra', 'Plus', 'Classic'])}",
                    manufacturer=random.choice(manufacturers),
                )
                session.add(b)
                brand_objs.append(b)
        await session.commit()
        print(f"Created {len(brand_objs)} brands")

        # -------------------------
        # PACKAGES (~50 total)
        # -------------------------
        package_objs = []
        target_packages = random.randint(MIN_PACKAGES, MAX_PACKAGES)
        while len(package_objs) < target_packages:
            product = random.choice(product_objs)
            # pick a brand that belongs to the product
            product_brands = [b for b in brand_objs if b.product_id == product.id]
            brand = random.choice(product_brands)
            pack_size = f"{random.choice([10, 20, 30, 50, 100])} pcs"
            country = random.choice(["DE", "SK"])
            # generate a unique-ish GTIN (13-digit string)
            gtin = "".join(str(random.randint(0, 9)) for _ in range(13))
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
        print(f"Created {len(package_objs)} packages")

        # -------------------------
        # PRODUCT IMAGES (1 per package, is_primary=True)
        # -------------------------
        image_objs = []
        for pkg in package_objs:
            # find the product name to make a slug
            prod_name = next(
                (p.inn_name for p in product_objs if p.id == pkg.product_id), "product"
            )
            img = ProductImage(
                id=gen_uuid(),
                package_id=pkg.id,
                image_url=make_image_url(prod_name, pkg.pack_size),
                is_primary=True,
            )
            session.add(img)
            image_objs.append(img)
        await session.commit()
        print(f"Created {len(image_objs)} product images")

        # -------------------------
        # TRANSLATIONS (de & sk for each product)
        # -------------------------
        translation_objs = []
        for p in product_objs:
            for lang in ("de", "sk"):
                tr = Translation(
                    id=gen_uuid(),
                    product_id=p.id,
                    language_code=lang,
                    translated_name=translate_for_lang(
                        p.inn_name, p.strength, p.form, lang
                    ),
                    translated_description="Description of a product. High-quality ingredients with trusted effectiveness. A popular choice among customers for its value.",
                )
                session.add(tr)
                translation_objs.append(tr)
        await session.commit()
        print(f"Created {len(translation_objs)} translations (de, sk)")

        # -------------------------
        # PHARMACIES (10, DE + SK)
        # -------------------------
        pharmacy_objs = []

        # force half Berlin, half Bratislava
        half = NUM_PHARMACIES // 2
        city_keys = ["Berlin"] * half + ["Bratislava"] * half
        random.shuffle(city_keys)

        for city in city_keys:
            country_code = COUNTRY_BY_CITY[city]
            if country_code == "DE":
                fake = fake_de
            else:
                fake = fake_sk

            lat0, lng0 = CITY_COORDS[city]
            lat = lat0 + random.uniform(-0.03, 0.03)
            lng = lng0 + random.uniform(-0.03, 0.03)
            ph = Pharmacy(
                id=gen_uuid(),
                name=f"{fake.company()} Apotheke",
                country=f"{country_code}",
                city=f"{city}",
                address=f"{fake.street_address()}",
                lat=str(round(lat, 6)),
                lng=str(round(lng, 6)),
                phone=fake.phone_number(),
                opening_hours={
                    "mon": "08:00-18:00",
                    "tue": "08:00-18:00",
                    "wed": "08:00-18:00",
                    "thu": "08:00-18:00",
                    "fri": "08:00-18:00",
                    "sat": "09:00-13:00",
                    "sun": "closed",
                },
            )
            session.add(ph)
            pharmacy_objs.append(ph)
        await session.commit()
        print(f"Created {len(pharmacy_objs)} pharmacies")

        # -------------------------
        # PHARMACY INVENTORY (random price per pharmacy)
        # -------------------------
        inventory_objs = []
        # Each pharmacy gets a random selection of packages (no duplicates per pharmacy)
        for ph in pharmacy_objs:
            sample_k = random.randint(8, min(15, len(package_objs)))
            sampled_packages = random.sample(package_objs, k=sample_k)
            for pkg in sampled_packages:
                # price cents vary by pharmacy — random base (199..1999 cents)
                price_cents = random.randint(199, 1999)
                stock_quantity = random.randint(1, 20)
                inv = PharmacyInventory(
                    id=gen_uuid(),
                    pharmacy_id=ph.id,
                    package_id=pkg.id,
                    price_cents=price_cents,
                    currency="EUR",
                    stock_quantity=stock_quantity,
                )
                session.add(inv)
                inventory_objs.append(inv)
        await session.commit()
        print(f"Created {len(inventory_objs)} pharmacy inventory entries")

    # summary
    print("✅ Seeding complete:")
    print(f"   Products: {len(product_objs)}")
    print(f"   Brands: {len(brand_objs)}")
    print(f"   Packages: {len(package_objs)}")
    print(f"   Images: {len(image_objs)}")
    print(f"   Translations: {len(translation_objs)}")
    print(f"   Pharmacies: {len(pharmacy_objs)}")
    print(f"   Inventory rows: {len(inventory_objs)}")


if __name__ == "__main__":
    asyncio.run(main())
