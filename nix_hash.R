#* Return the sri hash of a path using `nix hash path --sri path`
#* @param repo_url URL to Github repository
#* @param branchName Branch to checkout
#* @param commit Commit hash
#* @get /hash
function(repo_url, branchName, commit) {
  hash_git <- function(repo_url, branchName, commit){
    path_to_repo <- paste0(tempdir(), "repo",
                           paste0(sample(letters, 5), collapse = ""))

    git2r::clone(
             url = repo_url,
             local_path = path_to_repo,
             branch = branchName
           )

    git2r::checkout(path_to_repo, branch = commit)

    unlink(paste0(path_to_repo, "/.git"), recursive = TRUE, force = TRUE)

    command <- paste0("nix hash path --sri ", path_to_repo)

    output <- system(command, intern = TRUE)

    unlink(path_to_repo, recursive = TRUE, force = TRUE)

    return(output)
  }

  hash_cran <- function(repo_url){

    path_to_folder <- paste0(tempdir(), "repo",
                           paste0(sample(letters, 5), collapse = ""))

    dir.create(path_to_folder)

    path_to_tarfile <- paste0(path_to_folder, "/package.tar.gz")

    path_to_src <- paste0(path_to_folder, "/package_src")

    dir.create(path_to_src)

    download.file(url = repo_url,
                  destfile = path_to_tarfile)

    #untar(tarfile = path_to_tarfile, exdir = path_to_src)

    tar_command <- paste("tar", "-xvf", path_to_tarfile, "-C",
                         path_to_src, "--strip-components", 1)

    system(tar_command)

    command <- paste0("nix hash path --sri ", path_to_src)

    output <- system(command, intern = TRUE)

    unlink(path_to_folder, recursive = TRUE, force = TRUE)

    return(output)

  }

  if(grepl("github", repo_url)){
    hash_git(repo_url, branchName, commit)
  } else if(grepl("cran.*Archive.*", repo_url)){
    hash_cran(repo_url)
  } else {
    stop("repo_url argument is wrong. Please provide an url to a Github repo to install a package from Github, or to the CRAN Archive to install a package from the CRAN archive.")
  }

}

