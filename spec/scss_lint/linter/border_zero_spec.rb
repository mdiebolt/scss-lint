require 'spec_helper'

describe SCSSLint::Linter::BorderZero do
  context 'when a rule is empty' do
    context 'scss' do
      let(:scss) { <<-SCSS }
        p {
        }
      SCSS

      it { should_not report_lint }
    end

    context 'sass' do
      let(:sass) { <<-SASS }
        p
      SASS

      it { should_not report_lint }
    end
  end

  context 'when a property' do
    context 'contains a normal border' do
      context 'scss' do
        let(:scss) { <<-SCSS }
          p {
            border: 1px solid #000;
          }
        SCSS

        it { should_not report_lint }
      end

      context 'sass' do
        let(:sass) { <<-SASS }
          p
            border: 1px solid #000
        SASS

        it { should_not report_lint }
      end
    end

    context 'has a border of 0' do
      context 'scss' do
        let(:scss) { <<-SCSS }
          p {
            border: 0;
          }
        SCSS

        it { should_not report_lint }
      end

      context 'sass' do
        let(:sass) { <<-SASS }
          p
            border: 0
        SASS

        it { should_not report_lint }
      end
    end

    context 'has a border of none' do
      context 'scss' do
        let(:scss) { <<-SCSS }
          p {
            border: none;
          }
        SCSS

        it { should report_lint line: 2 }
      end

      context 'sass' do
        let(:sass) { <<-SASS }
          p
            border: none
        SASS

        it { should report_lint line: 2 }
      end
    end

    context 'has a border-top of none' do
      context 'scss' do
        let(:scss) { <<-SCSS }
          p {
            border-top: none;
          }
        SCSS

        it { should report_lint line: 2 }
      end

      context 'sass' do
        let(:sass) { <<-SASS }
          p
            border-top: none
        SASS

        it { should report_lint line: 2 }
      end
    end

    context 'has a border-right of none' do
      context 'scss' do
        let(:scss) { <<-SCSS }
          p {
            border-right: none;
          }
        SCSS

        it { should report_lint line: 2 }
      end

      context 'sass' do
        let(:sass) { <<-SASS }
          p
            border-right: none
        SASS

        it { should report_lint line: 2 }
      end
    end

    context 'has a border-bottom of none' do
      context 'scss' do
        let(:scss) { <<-SCSS }
          p {
            border-bottom: none;
          }
        SCSS

        it { should report_lint line: 2 }
      end

      context 'sass' do
        let(:sass) { <<-SASS }
          p
            border-bottom: none
        SASS

        it { should report_lint line: 2 }
      end
    end

    context 'has a border-left of none' do
      context 'scss' do
        let(:scss) { <<-SCSS }
          p {
            border-left: none;
          }
        SCSS

        it { should report_lint line: 2 }
      end

      context 'sass' do
        let(:sass) { <<-SASS }
          p
            border-left: none
        SASS

        it { should report_lint line: 2 }
      end
    end
  end

  context 'when a convention of `none` is preferred' do
    let(:linter_config) { { 'convention' => 'none' } }

    context 'and the border is `none`' do
      context 'scss' do
        let(:scss) { <<-SCSS }
          p {
            border: none;
          }
        SCSS

        it { should_not report_lint }
      end

      context 'sass' do
        let(:sass) { <<-SASS }
          p
            border: none
        SASS

        it { should_not report_lint }
      end
    end

    context 'and the border is `0`' do
      context 'scss' do
        let(:scss) { <<-SCSS }
          p {
            border: 0;
          }
        SCSS

        it { should report_lint }
      end

      context 'sass' do
        let(:sass) { <<-SASS }
          p
            border: 0
        SASS

        it { should report_lint }
      end
    end

    context 'and the border is a non-zero value' do
      context 'scss' do
        let(:scss) { <<-SCSS }
          p {
            border: 5px;
          }
        SCSS

        it { should_not report_lint }
      end

      context 'sass' do
        let(:sass) { <<-SASS }
          p
            border: 5px
        SASS

        it { should_not report_lint }
      end
    end
  end
end
