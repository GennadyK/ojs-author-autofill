{**
 * templates/controllers/grid/users/author/form/authorForm.tpl
 *
 * Copyright (c) 2014-2021 Simon Fraser University
 * Copyright (c) 2003-2021 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * Submission Contributor grid form
 *
 *}

<script>
	$(function() {ldelim}
		$('#editAuthor').pkpHandler(
			'$.pkp.controllers.form.AjaxFormHandler'
		);
	{rdelim});
</script>

<form class="pkp_form" id="editAuthor" method="post" action="{url op="updateAuthor" authorId=$authorId}">
	{csrf}
	{include file="controllers/notification/inPlaceNotification.tpl" notificationId="authorFormNotification"}
	
{* CUSTOM: Past Author Autofill | 2026-11-04
   Display previously used authors for autofilling contributor details. *}
{if $previousAuthors}
	<div class="pkp_form">
		<label for="previousAuthor">Select a previous author to autofill:</label>
		<select id="previousAuthor">
			<option value="">-- Select an author --</option>
			{foreach from=$previousAuthors item=previousAuthor}
				<option
					data-given-name="{$previousAuthor.givenName|json_encode|escape:'html'}"
					data-family-name="{$previousAuthor.familyName|json_encode|escape:'html'}"
					data-preferred-public-name="{$previousAuthor.preferredPublicName|json_encode|escape:'html'}"
					data-affiliation="{$previousAuthor.affiliation|json_encode|escape:'html'}"
					data-biography="{$previousAuthor.biography|json_encode|escape:'html'}"
					data-url="{$previousAuthor.url|escape}"
					data-last-modified="{$previousAuthor.lastModified|escape}"
					data-country="{$previousAuthor.country|escape}"
					data-email="{$previousAuthor.email|escape}"
					data-author-id="{$previousAuthor.authorId|escape}"
					data-orcid="{$previousAuthor.orcid|escape}"
				>
					{$previousAuthor.preferredPublicName.en_US|escape} (ID: {$previousAuthor.authorId})
				</option>
			{/foreach}
		</select>
	</div>
{/if}

<script>
	$(function() {
		$('#previousAuthor').on('change', function() {
			var author = $(this).find(':selected');

			if (!author.val() && !author.attr('data-given-name')) {
				return;
			}

			// CUSTOM: Past Author Autofill | 2026-11-04
			// Populate localized contributor details and standard author fields.

			function getLocalizedValue(attribute, locale) {
				var values = {};

				try {
					values = JSON.parse(author.attr(attribute) || '{}');
				} catch (e) {
					return '';
				}

				return values[locale] || '';
			}

			// Populate localized given names.
			$('#editAuthor input[id^="givenName"]').each(function() {
				var locale = this.name.match(/\[([^\]]+)\]/)[1];
				$(this).val(getLocalizedValue('data-given-name', locale));
			});

			// Populate localized family names.
			$('#editAuthor input[id^="familyName"]').each(function() {
				var locale = this.name.match(/\[([^\]]+)\]/)[1];
				$(this).val(getLocalizedValue('data-family-name', locale));
			});

			// Populate localized preferred public names.
			$('#editAuthor input[id^="preferredPublicName"]').each(function() {
				var locale = this.name.match(/\[([^\]]+)\]/)[1];
				$(this).val(getLocalizedValue('data-preferred-public-name', locale));
			});

			// Populate localized affiliations.
			$('#editAuthor input[id^="affiliation"]').each(function() {
				var locale = this.name.match(/\[([^\]]+)\]/)[1];
				$(this).val(getLocalizedValue('data-affiliation', locale));
			});

			// Populate email, URL, and ORCID.
			$('#editAuthor [name="email"]').val(author.attr('data-email') || '');
			$('#editAuthor [name="userUrl"]').val(author.attr('data-url') || '');
			$('#editAuthor [name="orcid"]').val(author.attr('data-orcid') || '');

			// Populate localized biographies and update TinyMCE editors.
			$('#editAuthor textarea[name^="biography["]').each(function() {
				var locale = this.name.match(/\[([^\]]+)\]/)[1];
				var biography = getLocalizedValue('data-biography', locale);

				$(this).val(biography);

				if (typeof tinymce !== 'undefined') {
					var editor = tinymce.get(this.id);
					if (editor) {
						editor.setContent(biography);
					}
				}
			});

			// Populate country.
			$('#editAuthor #country').val(author.attr('data-country') || '').trigger('change');
		});
	});
</script>

	{include
		file="common/userDetails.tpl"
		disableUserNameSection=true
		disableAuthSourceSection=true
		disablePasswordSection=true
		disableSendNotifySection=true
		disableSalutationSection=true
		disableInitialsSection=true
		disablePhoneSection=true
		disableLocaleSection=true
		disableInterestsSection=true
		disableMailingSection=true
		disableSignatureSection=true
		extraContentSectionUnfolded=true
		countryRequired=true
	}

	{fbvFormArea id="submissionSpecific"}
		{if $requireAuthorCompetingInterests}
			{fbvFormSection title="author.competingInterests"}
				{fbvElement id="competingInterests" type="textarea" multilingual=true rich=true label="author.competingInterests.description" value=$competingInterests}
			{/fbvFormSection}
		{/if}
		
		{* CUSTOM: Past Author Autofill | 2026-11-04
		Preselect Author by default while allowing other roles to be selected. *}
		{fbvFormSection id="userGroupId" title="submission.submit.contributorRole" list=true required=true}
			{iterate from=authorUserGroups item=userGroup}
				{if $userGroup->getLocalizedName() == 'Author'}
					{assign var="checked" value=true}
				{else}
					{assign var="checked" value=false}
				{/if}
				{fbvElement type="radio" id="userGroup"|concat:$userGroup->getId() name="userGroupId" value=$userGroup->getId() checked=$checked label=$userGroup->getLocalizedName() translate=false}
			{/iterate}
		{/fbvFormSection}
		{fbvFormSection list="true"}
			{fbvElement type="checkbox" label="submission.submit.selectPrincipalContact" id="primaryContact" checked=$primaryContact}
			{fbvElement type="checkbox" label="submission.submit.includeInBrowse" id="includeInBrowse" checked=$includeInBrowse}
			{$additionalCheckboxes}
		{/fbvFormSection}
	{/fbvFormArea}

	{if $submissionId}
		<input type="hidden" name="submissionId" value="{$submissionId|escape}" />
	{/if}
	{if $publicationId}
		<input type="hidden" name="publicationId" value="{$publicationId|escape}" />
	{/if}
	{if $gridId}
		<input type="hidden" name="gridId" value="{$gridId|escape}" />
	{/if}
	{if $rowId}
		<input type="hidden" name="rowId" value="{$rowId|escape}" />
	{/if}

	<p><span class="formRequired">{translate key="common.requiredField"}</span></p>
	{fbvFormButtons id="step2Buttons" submitText="common.save"}
</form>
