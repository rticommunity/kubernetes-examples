#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Migration Guide Links Definitions for RTI Connext user's manuals
#
# This file contains only variables that represent links to specific sections
# of the RTI Connext User's Manual, with version equals to the
# RTI Connext DDS version.
#

RTI_VERSION = '6.0.1'

LINK_RTI_COMMUNITY_DOC_s = 'https://community.rti.com/documentation/rti-connext-dds-%s'

LINK_CONNEXT_DOCS_s = 'https://community.rti.com/static/documentation/connext-dds/%s/doc'

LINK_RTI_COMMUNITY_DOC_CURRENT = LINK_RTI_COMMUNITY_DOC_s % '600'

LINK_CONNEXT_DOCS_CURRENT = LINK_CONNEXT_DOCS_s % RTI_VERSION

LINK_CONNEXT_MANUAL_DOCS_PREFIX = '%s/manuals' \
    % LINK_CONNEXT_DOCS_CURRENT

LINK_CONNEXT_MANUAL_DOCS_PREFIX_s = '%s/manuals' \
    % LINK_CONNEXT_DOCS_s

LINK_CONNEXT_USERS_MAN = '%s/connext_dds/html_files/' \
    'RTI_ConnextDDS_CoreLibraries_UsersManual/index.htm' \
    % LINK_CONNEXT_MANUAL_DOCS_PREFIX
