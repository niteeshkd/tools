"""create test table

Revision ID: 73109d73e7af
Revises: 
Create Date: 2024-02-08 19:41:38.497703

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '73109d73e7af'
down_revision = None
branch_labels = None
depends_on = None


# Define the upgrade and downgrade functions
def upgrade():
    op.create_table(
        'users',
        sa.Column('id', sa.Integer, primary_key=True),
        sa.Column('username', sa.String(length=50), nullable=False),
        sa.Column('email', sa.String(length=255), nullable=False, unique=True)
    )


def downgrade():
    op.drop_table('users')


