"""Added translations table
Revision ID: 0dc2e3b71fd0
Revises: d50e6c863412
Create Date: 2025-09-02 15:18:55.348626

"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "d50e6c863412"
down_revision: Union[str, Sequence[str], None] = "01a4d753aa07"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
