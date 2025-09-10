"""add pg_trgm and indexes

Revision ID: 2ca1f0fb2d13
Revises: 8c251db17dc2
Create Date: 2025-09-05 20:06:46.008863

"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision: str = "2ca1f0fb2d13"
down_revision: Union[str, Sequence[str], None] = "8c251db17dc2"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade():
    # Extension (once per DB)
    op.execute("CREATE EXTENSION IF NOT EXISTS pg_trgm;")

    # Fuzzy search indexes
    op.execute(
        "CREATE INDEX IF NOT EXISTS idx_products_inn_trgm ON products USING gin (inn_name gin_trgm_ops);"
    )
    op.execute(
        "CREATE INDEX IF NOT EXISTS idx_products_atc_trgm ON products USING gin (atc_code gin_trgm_ops);"
    )
    op.execute(
        "CREATE INDEX IF NOT EXISTS idx_brand_name_trgm ON brands USING gin (brand_name gin_trgm_ops);"
    )
    op.execute(
        "CREATE INDEX IF NOT EXISTS idx_translation_name_trgm ON translations USING gin (translated_name gin_trgm_ops);"
    )

    # Joins & filters
    op.execute(
        "CREATE INDEX IF NOT EXISTS idx_packages_product_id ON packages(product_id);"
    )
    op.execute(
        "CREATE INDEX IF NOT EXISTS idx_packages_brand_id ON packages(brand_id);"
    )
    op.execute(
        "CREATE INDEX IF NOT EXISTS idx_inventories_package_id ON pharmacy_inventory(package_id);"
    )
    op.execute(
        "CREATE INDEX IF NOT EXISTS idx_inventories_pharmacy_id ON pharmacy_inventory(pharmacy_id);"
    )

    # Common filters
    op.execute(
        "CREATE INDEX IF NOT EXISTS idx_inventories_pkg_stock ON pharmacy_inventory(package_id, stock_quantity);"
    )
    op.execute(
        "CREATE INDEX IF NOT EXISTS idx_inventories_pkg_price ON pharmacy_inventory(package_id, price_cents);"
    )

    # Translations
    op.execute(
        "CREATE INDEX IF NOT EXISTS idx_translations_prod_lang ON translations(product_id, language_code);"
    )

    # Geo filters
    op.execute(
        "CREATE INDEX IF NOT EXISTS idx_pharmacies_lat_lng ON pharmacies(lat, lng);"
    )


def downgrade():
    # Drop in reverse order (optional, but good practice)
    op.execute("DROP INDEX IF EXISTS idx_pharmacies_lat_lng;")
    op.execute("DROP INDEX IF EXISTS idx_translations_prod_lang;")
    op.execute("DROP INDEX IF EXISTS idx_inventories_pkg_price;")
    op.execute("DROP INDEX IF EXISTS idx_inventories_pkg_stock;")
    op.execute("DROP INDEX IF EXISTS idx_inventories_pharmacy_id;")
    op.execute("DROP INDEX IF EXISTS idx_inventories_package_id;")
    op.execute("DROP INDEX IF EXISTS idx_packages_brand_id;")
    op.execute("DROP INDEX IF EXISTS idx_packages_product_id;")
    op.execute("DROP INDEX IF EXISTS idx_translation_name_trgm;")
    op.execute("DROP INDEX IF EXISTS idx_brand_name_trgm;")
    op.execute("DROP INDEX IF EXISTS idx_products_atc_trgm;")
    op.execute("DROP INDEX IF EXISTS idx_products_inn_trgm;")

    # (Extensions can’t be dropped safely if others depend on them, but you could:)
    # op.execute("DROP EXTENSION IF EXISTS pg_trgm;")
