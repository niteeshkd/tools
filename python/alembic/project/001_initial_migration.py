from alembic import op
import sqlalchemy as sa


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

