# alembic/seeds/seed_data.py

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.models.bookings import Booking
from app.models.pharmacies import Pharmacy
from app.models.product import Product


def seed_database(engine):
    """
    Function to seed the database with test data.
    """
    Session = sessionmaker(bind=engine)
    session = Session()

    try:
        # Example: Check if data already exists to prevent duplicates
        if session.query(Product).count() == 0:
            print("Seeding products...")
            product1 = Product(
                id="1",
                name="Paracetamol",
                form="pills",
                strength="200g",
                gtin="126456126",
                price_cents="1275",
                currency="EUR",
                pharmacy_id="1",
            )
            product2 = Product(
                id="2",
                name="Paracetamol 50g",
                form="pills",
                strength="50g",
                gtin="45612345",
                price_cents="1657",
                currency="EUR",
                pharmacy_id="2",
            )
            session.add_all([product1, product2])
            session.commit()

            print("Seeding Pharmacies...")

            simple_hours = {
                "monday": "9am - 5pm",
                "tuesday": "9am - 5pm",
                "wednesday": "9am - 5pm",
                "thursday": "9am - 5pm",
                "friday": "9am - 5pm",
                "saturday": "10am - 2pm",
                "sunday": "Closed",
            }

            pharma1 = Pharmacy(
                id="1",
                name="FancyOne",
                address="Schinahui 2, 86F",
                lat="23",
                lng="76",
                phone="+123456845",
                opening_hours=simple_hours,
            )
            pharma2 = Pharmacy(
                id="2",
                name="FancyOne2",
                address="Schinahui 10, 86F",
                lat="23",
                lng="77",
                phone="+312456845",
                opening_hours=simple_hours,
            )
            session.add_all([pharma1, pharma2])
            session.commit()
        else:
            print("Database already contains data. Skipping seeding.")

    except Exception as e:
        session.rollback()
        print(f"An error occurred during seeding: {e}")
    finally:
        session.close()


if __name__ == "__main__":
    # This block is for running the script directly
    # You'll need to configure your database connection string here

    engine = create_engine(DATABASE_URL)
    seed_database(engine)
