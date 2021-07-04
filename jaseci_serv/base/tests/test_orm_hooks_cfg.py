from django.contrib.auth import get_user_model

from jaseci.utils.utils import TestCaseHelper
from django.test import TestCase

from base.models import GlobalConfig
from jaseci.utils.mem_hook import mem_hook

# Alias for create user
create_user = get_user_model().objects.create_user
get_user = get_user_model().objects.get


class jaseci_engine_orm_config_tests_private(TestCaseHelper, TestCase):
    """Test Jaseci Engine when authenticated"""

    def setUp(self):
        super().setUp()
        self.user = create_user(
            email='JSCadft@jaseci.com',
            password='testpass',
            name='some dude',
        )
        self._h = mem_hook()

    def tearDown(self):
        super().tearDown()

    def test_jsci_db_to_engine_hook_saving(self):
        """Test that db hooks are set up correctly for saving"""
        user = self.user
        self.assertIsNotNone(user._h)
        h = user._h
        h.save_cfg('GOOBY', 'MOOBY')
        h.commit()

        load_test = GlobalConfig.objects.get(name='GOOBY')
        self.assertEqual(load_test.value, 'MOOBY')

    def test_jsci_db_to_engine_hook_loading(self):
        """Test that db hooks are set up correctly for loading"""
        user = self.user
        self.assertIsNotNone(user._h)
        h = user._h
        h.save_cfg('GOOBY1', 'MOOBY1')
        h.commit()

        del user._h.mem['GOOBY1']
        user._h.red.delete('GOOBY1')
        self.assertNotIn('GOOBY1', user._h.mem.keys())

        load_test = GlobalConfig.objects.filter(name='GOOBY1').first()
        self.assertIsInstance(load_test, GlobalConfig)

        user._h.get_cfg('GOOBY1')
        self.assertEqual(user._h.mem['GOOBY1'], 'MOOBY1')