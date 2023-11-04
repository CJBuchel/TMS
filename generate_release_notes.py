import requests
import argparse
from datetime import datetime

# Configuration
repo_owner = 'CJBuchel'  # Replace with your GitHub username or organization
repo_name = 'TMS'  # Replace with your repository name
release_notes_file = 'RELEASE_NOTES.md'  # Output file for release notes

def get_items(url, params=None):
    """Fetch items from GitHub API URL"""
    items = []
    while url:
        response = requests.get(url, params=params)
        response.raise_for_status()
        items.extend(response.json())
        url = response.links.get('next', {}).get('url')  # Get next page if available
    return items

def get_latest_release():
    """Get the latest full release data including tag name and publish date"""
    url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/releases/latest"
    response = requests.get(url)
    response.raise_for_status()
    latest_release = response.json()
    latest_release_date = datetime.strptime(latest_release['published_at'], '%Y-%m-%dT%H:%M:%SZ')
    latest_release_tag = latest_release['tag_name']
    return latest_release_date, latest_release_tag

def generate_comparison_link(old_tag, new_tag):
    """Generate a GitHub comparison link between two releases"""
    return f"https://github.com/{repo_owner}/{repo_name}/compare/{old_tag}...{new_tag}"


def generate_release_notes(issues, pull_requests, latest_release_date):
    """Generate markdown formatted release notes"""
    release_notes = "# Release Notes\n\n"

    # pull requests
    release_notes += "\n## Merged Pull Requests\n"
    for pr in pull_requests:
        if pr['merged_at'] and datetime.strptime(pr['merged_at'], '%Y-%m-%dT%H:%M:%SZ') > latest_release_date:
            release_notes += f"- PR #{pr['number']}: {pr['title']} (by @{pr['user']['login']})\n"
    
    release_notes += "## Resolved Issues\n"
    for issue in issues:
        if issue['closed_at'] and datetime.strptime(issue['closed_at'], '%Y-%m-%dT%H:%M:%SZ') > latest_release_date:
            release_notes += f"- Issue #{issue['number']}: {issue['title']} (by @{issue['user']['login']})\n"
 
    return release_notes

def main(latest_tag):
    latest_release_date, latest_release_tag = get_latest_release()

    params = {
        'state': 'closed',
        'filter': 'all',
        'since': latest_release_date.isoformat()
    }
    
    issues_url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/issues"
    prs_url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/pulls"

    issues = get_items(issues_url, params)
    pull_requests = get_items(prs_url, params)

    # Filter out PRs from issues as GitHub API returns PRs as issues as well
    issues = [issue for issue in issues if 'pull_request' not in issue]
    # Filter out unmerged PRs
    pull_requests = [pr for pr in pull_requests if pr['merged_at'] is not None]

    release_notes = generate_release_notes(issues, pull_requests, latest_release_date)
    
    comparison_link = generate_comparison_link(latest_release_tag, latest_tag)
    release_notes += f"\n## Full Changes\n[View the full changes between {latest_release_tag} and {latest_tag}]({comparison_link})\n"

    with open(release_notes_file, 'w') as file:
        file.write(release_notes)
    
    print(f"Release notes generated successfully and saved to {release_notes_file}.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate release notes for a GitHub project.')
    parser.add_argument('latest_tag', type=str, help='The tag for the current release')
    args = parser.parse_args()
    
    main(args.latest_tag)