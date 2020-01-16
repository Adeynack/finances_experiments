# == Schema Information
#
# Table name: books
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string           not null
#  owner_id   :uuid             not null
#

require "rails_helper"

RSpec.describe Book do
  describe "when creating a user" do
    User.find_by(email: "mister-t@a.team")&.destroy
    mister_t = User.create email: "mister-t@a.team", display_name: "Mister T"
    it("has the right email") { expect(mister_t.email).to eq "mister-t@a.team" }
    it("has the right display name") { expect(mister_t.display_name).to eq "Mister T" }

    describe "it is possible to add a book using `user.books.create`" do
      book = mister_t.books.create name: "Foo Book"
      it("has the right name") { expect(book.name).to eq "Foo Book" }
      it("has the right owner") { expect(book.owner).to eq mister_t }
    end

    describe "it is possible to add a book using `Book.create`" do
      book = described_class.create name: "Bar Book", owner: mister_t
      it("has the right name") { expect(book.name).to eq "Bar Book" }
      it("has the right owner") { expect(book.owner.id).to eq mister_t.id }
    end
  end
end
