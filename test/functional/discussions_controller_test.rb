require 'test_helper'

class DiscussionsControllerTest < ActionController::TestCase
  SUBJECT_VALID = "Foo"
  SUBJECT_TOO_LONG = "f" * 51
  CONTENT_VALID = "Lorem Ipsum"
  
  DEFAULT_OPTIONS = {
    subject: SUBJECT_VALID,
    content: CONTENT_VALID
  }
  
  # TODO: use model.reload instead of updated_model?
  
  setup do
    @john = users(:john)
    @jane = users(:jane)
    @admin = users(:admin)
    @discussion_with_comments = discussions(:discussion_with_comments)
    @discussion_without_comments = discussions(:discussion_without_comments)
  end

   # Show discussions-------------------------------------------------

  test "user should sign in before viewing discussions" do
    make_sure_user_is_not_signed_in
    
    get :index

    assert_redirected_to signin_path
  end

  test "user can view discussions after sign in" do
    sign_in @john

    get :index

    assert_template 'index'
    assert_select 'title', 'SocialCamp | Discussions'
    assert_select 'div#discussions', count: 1
  end

  test "discussions page should display the same number of discussions as in discussions variable" do
    sign_in @john

    get :index

    assert_response :success
    assert_not_nil assigns(:discussions)
    assert_select 'tr[id *= discussion-]', count: assigns(:discussions).size
  end

  test "discussions page should display links for 'new discussion' and 'rss'" do
    sign_in @john

    get :index

    assert_response :success
    assert_select 'a#discussion-new-link', count: 1
    assert_select 'span#rss', count: 1
  end

  # Create discussion-------------------------------------------------

  test "user should signin before visiting create discussion page" do
    make_sure_user_is_not_signed_in

    get :new

    assert_redirected_to signin_path
  end

  test "user should be able to view new discussion page after sign in" do
    sign_in @john

    get :new

    assert_select 'title', 'SocialCamp | Create new discussion'
    assert_select 'div#discussion-new', count: 1
    assert_select 'a#discussions-link', count: 1
  end

  test "user should signin before creating discussion" do
    make_sure_user_is_not_signed_in
    
    post :create, discussion: DEFAULT_OPTIONS
    
    assert_redirected_to signin_path
  end

  test "discussion should not be created when subject is not provided" do
    sign_in @john

    post :create, discussion: DEFAULT_OPTIONS.merge({ subject: nil })

    discussion = Discussion.find_by_content DEFAULT_OPTIONS[:content]
    assert discussion.nil?
    assert_template 'new'
  end

  test "discussion should not be created when content is not provided" do
    sign_in @john

    post :create, discussion: DEFAULT_OPTIONS.merge({ content: nil })

    discussion = Discussion.find_by_subject DEFAULT_OPTIONS[:subject]
    assert discussion.nil?
    assert_template 'new'
  end

  test "discussion should be created when valid info (subject and content) is provided" do
    sign_in @john

    post :create, discussion: DEFAULT_OPTIONS

    assert_redirected_to discussions_path

    created_discussion = Discussion.find_by_subject DEFAULT_OPTIONS[:subject]

    refute created_discussion.nil?
    assert_equal DEFAULT_OPTIONS[:content], created_discussion.content
    assert_equal @john, created_discussion.user
  end

  test "upon successful discussion creation there should be a changelog" do
    sign_in @john

    post :create, discussion: DEFAULT_OPTIONS

    created_discussion = Discussion.find_by_subject DEFAULT_OPTIONS[:subject]
    changelog = Changelog.of_trackable(created_discussion).last

    refute changelog.nil?
    assert_equal created_discussion, changelog.trackable
    assert_equal ActionType::ADD, changelog.action_type_id
    assert_equal @john.id, changelog.user_id
  end

  # Show discussion-------------------------------------------------

  test "user should sign in before viewing a discussion" do
    make_sure_user_is_not_signed_in
    discussion = @discussion_with_comments
    get :show, id: discussion.id

    assert_redirected_to signin_path
  end

  test "user can view a discussion after sign in" do
    sign_in @john

    discussion = @discussion_with_comments
    get :show, id: discussion.id

    assert_select 'title', 'SocialCamp | View discussion'
    assert_select 'div#discussion-show', count: 1
    assert_select 'div#discussion', count: 1
    assert_select 'div#comments', count: 1
    assert_select 'div#comment-new', count: 1
    assert_select 'div#links-discussions', count: 1
    assert_select 'a#discussions-link', count: 1
  end

  test "user who created the discussion should see links for 'edit' and 'delete' in show discussion page" do
    sign_in @john

    discussion = @discussion_with_comments # created by john
    get :show, id: discussion.id

    assert_select 'a#discussion-edit-link', count: 1
    assert_select 'a#discussion-delete-link', count: 1
  end

  test "admin should see links for 'edit' and 'delete' in show discussion page" do
    sign_in @admin

    discussion = @discussion_with_comments
    get :show, id: discussion.id

    assert_select 'a#discussion-edit-link', count: 1
    assert_select 'a#discussion-delete-link', count: 1
  end

  test "regular user should not see links for 'edit' and 'delete' in show discussion page" do
    sign_in @jane

    discussion = @discussion_with_comments
    get :show, id: discussion.id

    assert_select 'a#discussion-edit-link', false
    assert_select 'a#discussion-delete-link', false
  end

  # Edit discussion-------------------------------------------------

  test "user should sign in before viewing edit discussion page" do
    make_sure_user_is_not_signed_in
    discussion = @discussion_with_comments
    get :edit, id: discussion.id

    assert_redirected_to signin_path
  end

  test "user cannot view edit page of a discussion created by others" do
    sign_in @jane

    discussion = @discussion_with_comments # created by john
    get :edit, id: discussion.id

    assert_redirected_to discussions_path
  end

  test "user can view edit page of a discussion created by herself" do
    sign_in @john

    discussion = @discussion_with_comments # created by john
    get :edit, id: discussion.id

    assert_select 'title', 'SocialCamp | Edit discussion'
    assert_select 'div#discussion-edit', count: 1
    assert_select 'a#discussion-view-link', count: 1
    assert_select 'a#discussion-delete-link', count: 1
  end

  test "admin can view edit page of a discussion created by others" do
    sign_in @admin

    discussion = @discussion_with_comments # created by john
    get :edit, id: discussion.id

    assert_select 'title', 'SocialCamp | Edit discussion'
    assert_select 'div#discussion-edit', count: 1
    assert_select 'a#discussion-view-link', count: 1
    assert_select 'a#discussion-delete-link', count: 1
  end

  # Update discussion-------------------------------------------------

  test "user should sign in before update a discussion" do
    make_sure_user_is_not_signed_in
    discussion = @discussion_with_comments
    put :update, id: discussion.id

    assert_redirected_to signin_path
  end

  test "user cannot update a discussion created by others" do
    sign_in @jane

    discussion = @discussion_with_comments # created by john
    put :update, id: discussion.id

    assert_redirected_to discussions_path
  end

  test "discussion should not be updated when subject is not provided" do
    sign_in @john

    old_subject = @discussion_with_comments.subject
    updated_content = "Lorem Ipsum"
    put :update, id: @discussion_with_comments.id, discussion: { subject: nil,
                                                                 content: updated_content }

    discussion = Discussion.find @discussion_with_comments.id
    assert_equal old_subject, discussion.subject
    assert_template 'edit'
  end

  test "discussion should not be updated when content is not provided" do
    sign_in @john

    old_content = @discussion_with_comments.content
    updated_subject = "foobar"
    put :update, id: @discussion_with_comments.id, discussion: { subject: updated_subject,
                                                                 content: nil }

    discussion = Discussion.find @discussion_with_comments.id
    assert_equal old_content, discussion.content
    assert_template 'edit'
  end

  test "user can update a discussion created by herself" do
    sign_in @john

    discussion = @discussion_with_comments # created by john
    updated_subject = "foobar"
    updated_content = "Lorem Ipsum"
    put :update, id: discussion.id, discussion: { subject: updated_subject,
                                                  content: updated_content }

    assert_redirected_to discussion

    updated_discussion = Discussion.find discussion.id

    assert_equal updated_subject, updated_discussion.subject
    assert_equal updated_content, updated_discussion.content
    assert_equal @john.id, updated_discussion.user_id
  end

  test "admin can update a discussion created by another user" do
    sign_in @admin

    discussion = @discussion_with_comments
    updated_subject = "foobar"
    updated_content = "Lorem Ipsum"
    put :update, id: discussion.id, discussion: { subject: updated_subject,
                                                  content: updated_content }

    assert_redirected_to discussion

    updated_discussion = Discussion.find discussion.id

    assert_equal updated_subject, updated_discussion.subject
    assert_equal updated_content, updated_discussion.content
    # user_id of discussion should still be the original user
    # updates will be reflected in changelogs
    assert_not_equal @admin.id, updated_discussion.user_id
  end

  test "upon successful discussion update there should be a changelog" do
    sign_in @john

    discussion = @discussion_with_comments
    updated_subject = "foobar"
    updated_content = "Lorem Ipsum"
    put :update, id: discussion.id, discussion: { subject: updated_subject,
                                                  content: updated_content }

    assert_redirected_to discussion

    updated_discussion = Discussion.find discussion.id
    changelog = Changelog.of_trackable(updated_discussion).last

    assert_equal updated_discussion, changelog.trackable
    assert_equal ActionType::UPDATE, changelog.action_type_id
    assert_equal @john.id, changelog.user_id
  end

  # Destroy discussion-------------------------------------------------

  test "user should sign in before destroy a discussion" do
    make_sure_user_is_not_signed_in
    discussion = @discussion_with_comments
    delete :destroy, id: discussion.id

    assert_redirected_to signin_path
  end

  test "user cannot destroy a discussion created by others" do
    sign_in @jane

    discussion = @discussion_with_comments # created by john
    delete :destroy, id: discussion.id

    assert_redirected_to discussions_path

    discussion_attempted_to_destroy = Discussion.find discussion.id

    refute discussion_attempted_to_destroy.nil?
  end

  test "user can destroy a discussion created by herself" do
    sign_in @john

    discussion = @discussion_with_comments
    delete :destroy, id: discussion.id

    assert_redirected_to discussions_path

    discussion_attempted_to_destroy = Discussion.find_by_id discussion.id

    assert discussion_attempted_to_destroy.nil?
  end

  test "admin can destroy a discussion created by another user" do
    sign_in @admin

    discussion = @discussion_with_comments
    delete :destroy, id: discussion.id

    assert_redirected_to discussions_path

    discussion_attempted_to_destroy = Discussion.find_by_id discussion.id

    assert discussion_attempted_to_destroy.nil?
  end

  test "upon successful discussion destroy there should be a changelog for discussion" do
    sign_in @john

    discussion = @discussion_with_comments
    final_words = discussion.final_words
    delete :destroy, id: discussion.id

    discussion_attempted_to_destroy = Discussion.find_by_id discussion.id

    changelog = Changelog.find_all_by_trackable_type_and_trackable_id(
                            'Discussion', discussion.id)
                          .sort_by { |log| log.created_at }
                          .last

    assert discussion_attempted_to_destroy.nil?
    assert_equal final_words, changelog.destroyed_content_summary
    assert_equal ActionType::DESTROY, changelog.action_type_id
    assert_equal @john.id, changelog.user_id
  end

  test "upon successful discussion destroy comments should be destroyed" do
    sign_in @john

    discussion = @discussion_with_comments
    comments = discussion.comments.dup

    delete :destroy, id: discussion.id

    assert comments.count > 0

    comments.each do |c|
      comment = Comment.find_by_id c.id
      assert comment.nil?
    end
  end

  test "upon successful discussion destroy there should be changelogs for comments" do
    sign_in @john

    discussion = @discussion_with_comments

    comments = discussion.comments.dup
    delete :destroy, id: discussion.id

    assert comments.count > 0

    comments.each do |c|
      changelog = Changelog.find_all_by_trackable_type_and_trackable_id(
                            'Comment', c.id)
                            .last

      assert_equal c.final_words, changelog.destroyed_content_summary
      assert_equal ActionType::DESTROY, changelog.action_type_id
      assert_equal @john.id, changelog.user_id             
    end
  end

  test "upon successful discussion destroy by admin there should be changelogs for comments" do
    sign_in @admin

    discussion = @discussion_with_comments

    comments = discussion.comments.dup
    
    delete :destroy, id: discussion.id

    assert comments.count > 0

    comments.each do |c|
      changelog = Changelog.find_all_by_trackable_type_and_trackable_id(
                            'Comment', c.id)
                            .last

      assert_equal c.final_words, changelog.destroyed_content_summary
      assert_equal ActionType::DESTROY, changelog.action_type_id
      assert_equal @admin.id, changelog.user_id             
    end
  end

end
