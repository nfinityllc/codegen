package com.nfin.testemaa.domain.model.Temp;

import javax.persistence.*;

/**
 * Auto-generated by:
 * org.apache.openjpa.jdbc.meta.ReverseMappingTool$AnnotatedCodeGenerator
 */
@Entity
@Table(schema="blog", name="subscription")
@IdClass(com.nfin.testemaa.domain.model.Temp.SubscriptionId.class)
public class Subscription {
	@ManyToOne(fetch=FetchType.LAZY, cascade=CascadeType.MERGE)
	@JoinColumn(name="blog_id", columnDefinition="int8")
	private Blog blog;

	@Id
	@Column(name="blog_id", columnDefinition="int8")
	private long blogId;

	@ManyToOne(fetch=FetchType.LAZY, cascade=CascadeType.MERGE)
	@JoinColumn(name="user_id", columnDefinition="int8")
	private User user;

	@Id
	@Column(name="user_id", columnDefinition="int8")
	private long userId;


	public Subscription() {
	}

	public Subscription(long blogId, long userId) {
		this.blogId = blogId;
		this.userId = userId;
	}

	public Blog getBlog() {
		return blog;
	}

	public void setBlog(Blog blog) {
		this.blog = blog;
	}

	public long getBlogId() {
		return blogId;
	}

	public void setBlogId(long blogId) {
		this.blogId = blogId;
	}

	public User getUser() {
		return user;
	}

	public void setUser(User user) {
		this.user = user;
	}

	public long getUserId() {
		return userId;
	}

	public void setUserId(long userId) {
		this.userId = userId;
	}
}