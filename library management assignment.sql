drop database libraries;
create database libraries;
use libraries;

-- publisher table
drop table if exists publisher;
create table publisher(publisher_PublisherName varchar(30) primary key,publisher_PublisherAddress varchar(50),publisher_PublisherPhone varchar(50));
select * from publisher;

-- library branch table
drop table library_branch;
create table library_branch( libraryBranchID int primary key auto_increment,libraryBranchBranchName varchar(30),library_branch_BranchAddress varchar(50));

select * from library_branch;


--  borrower table
drop table if exists borrower;
create table borrower(borrower_CardNo int primary key,borrower_BorrowerName varchar(50),borrower_BorrowerAddress varchar(70),borrower_BorrowerPhone varchar(20));
select * from borrower;

-- books table
drop table if exists books;
create table books(book_BookID int primary key auto_increment,book_Title varchar(30),book_PublisherName varchar(30),foreign key(book_PublisherName)
 references  publisher(publisher_PublisherName));
select * from books;

-- authors table
drop table if exists book_authors;
create table book_authors(book_authors_authourID int primary key auto_increment,book_authors_BookID int,book_authors_AuthorName varchar(30),foreign key(book_authors_BookID)
references books(book_BookID));
select * from book_authors;

-- book loans table
drop table if exists book_loans;
create table book_loans(book_loans_BookID int,book_loans_BranchID int,book_loans_CardNo int,book_loans_DateOut varchar(10),book_loans_DueDate varchar(10), foreign key(book_loans_BranchID)
references books(book_BookID) , foreign key(book_loans_BranchID) references library_branch( libraryBranchID), foreign key(book_loans_CardNo) references borrower(borrower_CardNo));

select * from book_loans;

-- book copies table
drop table if exists book_copies;
create table book_copies(book_copies_copiesID Int primary key auto_increment,book_copies_BookID int,book_copies_BranchID int,book_copies_No_Of_Copies int, foreign key(book_copies_BookID)
references books(book_BookID), foreign key(book_copies_BranchID) references library_branch( libraryBranchID));
select * from book_copies;

-- 1.How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?

select b.book_Title,lbc.libraryBranchBranchName,lbc.book_copies_No_Of_Copies from
(select bc.book_copies_No_Of_Copies,bc.book_copies_BookID,lb.libraryBranchBranchName
from library_branch as lb
join book_copies as bc
on bc.book_copies_BranchID=lb.libraryBranchID 
where lb.libraryBranchBranchName = 'Sharpstown') as lbc
join books as b
on b.book_BookID =lbc.book_copies_BookID
where b.book_Title = 'The Lost Tribe';

-- 2.How many copies of the book titled "The Lost Tribe" are owned by each library branch?
select * from book_copies;
select * from books;
select * from library_branch;

select lb.libraryBranchBranchName,lbc.book_Title,lbc.book_copies_No_Of_Copies from
(select b.book_Title,bc.book_copies_No_Of_Copies,bc.book_copies_BranchID
from books as b
join book_copies as bc
on bc.book_copies_BookID= b.book_BookID
where b.book_Title = 'The Lost Tribe') as lbc
join library_branch as lb
on lbc.book_copies_BranchID = lb.libraryBranchID;

-- 3.Retrieve the names of all borrowers who do not have any books checked out.
select borrower_CardNo,borrower_BorrowerName 
from borrower where borrower_CardNo not in(select book_loans_CardNo from book_loans);

-- 4. For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18,
-- retrieve the book title, the borrower's name, and the borrower's address. 
select * from library_branch;
select * from book_loans;
select * from borrower;
select * from books;

with cte1 as
(select lb.libraryBranchBranchName,bl.book_loans_DateOut,bl.book_loans_CardNo,bl.book_loans_BookID
from library_branch as lb
join book_loans as bl
on lb.libraryBranchID=bl.book_loans_BranchID),
cte2 as
(select cte1.libraryBranchBranchName,cte1.book_loans_DateOut,cte1.book_loans_BookID,cte1.book_loans_CardNo,b.book_Title
from cte1
join books as b
on cte1.book_loans_BookID= b.book_BookID),
cte3 as
(select cte2.libraryBranchBranchName,cte2.book_loans_DateOut,cte2.book_loans_CardNo,bo.borrower_BorrowerName,bo.borrower_BorrowerAddress,cte2.book_loans_BookID,cte2.book_Title
from cte2
join borrower as bo
on cte2.book_loans_CardNo=bo.borrower_CardNo)
select libraryBranchBranchName,book_loans_DateOut,book_Title,borrower_BorrowerAddress,book_loans_BookID
from cte3
where book_loans_DateOut= ' 2/3/18' and libraryBranchBranchName='Sharpstown';

-- 5.For each library branch, retrieve the branch name and the total number of books loaned out from that branch.
select libraryBranchBranchName,book_copies_No_Of_Copies
from library_branch as lb
join book_copies as bc
on bc.book_copies_BranchID = lb.libraryBranchID;

-- 6.Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.
with cte1 as 
(select tlb.borrower_CardNo,tlb.borrower_BorrowerName,tlb.borrower_BorrowerAddress,l.book_loans_BookID,l.book_loans_CardNo
from borrower as tlb
join book_loans as l
on tlb.borrower_CardNo = l.book_loans_CardNo),
cte2 as
(select c1.borrower_BorrowerName,c1.borrower_BorrowerAddress,c1.book_loans_BookID,c1.book_loans_CardNo,b.book_Title
from cte1 as c1
join books as b
on c1.book_loans_BookID= b.book_BookID)
select borrower_BorrowerName, borrower_BorrowerAddress , book_loans_BookID as total
from cte2
where book_loans_BookID>'5'
order by total;

-- 7.For each book authored by "Stephen King",
-- retrieve the title and the number of copies owned by the library branch whose name is "Central".

WITH cte1 as
(select ba.book_authors_AuthorName,b.book_Title,b.book_BookID
from book_authors as ba
join books as b
on b.book_BookID=ba.book_authors_BookID
where ba.book_authors_AuthorName= 'Stephen King'),
 cte2 as
 (select cte1.book_authors_AuthorName,cte1.book_Title,cte1.book_BookID,bc.book_copies_No_Of_Copies as totalCopies,bc.book_copies_BranchID
 from cte1
 join book_copies as bc
 on bc.book_copies_BookID = cte1.book_BookID),
 cte3 as 
 (select cte2.book_authors_AuthorName,cte2.book_Title,cte2.totalCopies,lb.libraryBranchBranchName
 from library_branch as lb
 join cte2
 on cte2.book_copies_BranchID = lb.libraryBranchID)
 select book_authors_AuthorName,book_Title,totalCopies,libraryBranchBranchName
 from cte3
 where libraryBranchBranchName='Central';










